//
//  Webservice.swift
//  Webservice
//
//  Created by Mohammad Azam on 7/24/21.
//

import Foundation

enum NetworkError: Error {
  case badUrl
  case decodingError
  case badRequest
}

class Webservice {
  
  // making async/await method practice
  // - async/await 방식으로 처리하면서 escaping callback closure를 사용할 필요가 없어졌다.
  // - 콜백 클로져가 사라지면서 콜백 지옥을 방지할 수 있게되고, 간결하고 가독성 좋은 코드가 되었다.
  func getAllTodosAsync(url: URL) async throws -> [Todo] {
    do {
      let (data, _) = try await URLSession.shared.data(from: url)
      let todos = try JSONDecoder().decode([Todo].self, from: data)
      return todos
    } catch {
      print(error)
    }
    return []
  }

  // 인자 레이블 뒤에 @MainActor를 명시하면 해당 콜백이 main thread에서 isolated하게 동작함을 보장할 수 있다. DispatchQueue.main을 명시할 필요가 없어짐.
  // 물론, 아래의 코드는 마냥 좋다고 할 수는 없다 여전히 escaping callback closure를 사용하기 때문에 completion 호출 후 return을 하는 등 고려한 요소가 많아 실수를 통해 비정상 동작을 야기할 가능성이 커지기 때문이다.
  func getAllTodos(url: URL, completion: @MainActor @escaping (Result<[Todo], NetworkError>) -> Void) {
    
    URLSession.shared.dataTask(with: url) { data, _, error in
      
      guard let data = data, error == nil else {
        Task {
          // mainActor에 의해 main thread에서 동작하게 된다.
          await completion(.failure(.badRequest))
        }
        return
      }
      
      guard let todos = try? JSONDecoder().decode([Todo].self, from: data) else {
        Task {
          await completion(.failure(.decodingError))
        }
        return
      }
      
      Task {
        await completion(.success(todos))
      }
    }.resume()
    
  }
  
}
