// MARK: 28. Implementing a Get All Posts Callback Function Using Result Type
// First, let's implement the function with escaping callback closure the first to use continuation
// MARK: 29. Converting Callback Function to Async/Await Function Using Continuation
  
import UIKit

enum NetworkError: Error {
  case badURL
  case noData
  case decodingError
}

struct Post: Decodable {
  let title: String
}

func getPosts(completion: @escaping (Result<[Post], NetworkError>) -> Void) {
  guard let url = URL(string: "https://jsonplaceholder.typicode.com/posts") else {
    completion(.failure(.badURL))
    return
  }
  
  URLSession.shared.dataTask(with: url) { data, response, error in
    guard let data = data, error == nil else {
      completion(.failure(.noData))
      return
    }
    
    let posts = try? JSONDecoder().decode([Post].self, from: data)
    completion(.success(posts ?? []))
  }
  .resume()
}

// continuation method는 크게 네가지가 있다.
// 1) withCheckedContinuation
// 2) withCheckedThrowingContinuation
// 3) withUnsafeContinuation
// 4) withUnsafeThrowingContinuation

// 이제 아래 getPosts method 바깥에 continuation을 사용해서 외부에서 async/await하게 비동기 처리를 할 수 있도록 할 것임.
/*
getPosts { result in
  switch result {
  case .success(let posts):
    print(posts)
  case .failure(let error):
    print(error)
  }
}
*/

func getPosts() async throws -> [Post] {
  return try await withCheckedThrowingContinuation { continuation in
    // third party method등은 escaping callback closure 방식을 async await 방식으로 수정하기 곤란할 수 있다. 이럴때 continuation을 사용해서 외부에서 async/await하게 처리할 수 있다.
    getPosts { result in
      switch result {
      case .success(let posts):
        continuation.resume(returning: posts)
        print(posts)
      case .failure(let error):
        // throwingContinuation은 error를 throw 할 수도 있음
        continuation.resume(throwing: error)
        print(error)
      }
    }
  }
}

Task {
  do {
    // 외부에서는 escaping callback closure가 있는 레거시 or thrid party method를 사용할 필요가 없음
    // continuation을 사용한 async method를 외부에서 사용하면 async/await 하게 비동기 처리가 가능하며, 콜백 지옥을 방지하고 보다 간결하고 가독성 좋은 코드를 작성 가능함.
    let posts = try await getPosts()
    // 요청 성공 시, 아래에 응답결과가 출력
    print(posts)
  } catch {
    // error가 throw 되었다면 catch 블럭 내에서 error 내용이 출력
    print(error)
  }
}
