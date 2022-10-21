//
//  Webservice.swift
//  NewsApp
//
//  Created by Mohammad Azam on 6/30/21.
//

import Foundation

enum NetworkError: Error {
  case badUrl
  case invalidData
  case decodingError
}

class Webservice {
  
  // async/await 동작이 수행되는 메서드 반환 부 앞에는 async를 붙힌다. 만약 error를 throw한다면, async throws를 붙힌다.
  func fetchSources(url: URL?) async throws -> [NewsSource] {
    guard let url = url else {
      return []
    }
    // iOS 15부터는 URLSessiion으로 async throws function을 사용할 수 있어요.
    let (data, _) = try await URLSession.shared.data(from: url)
    let newsSourceResponse =  try? JSONDecoder().decode(NewsSourceResponse.self, from: data)
    return newsSourceResponse?.sources ?? []
  }
  
  func fetchNewsAsync(sourceId: String, url: URL?) async throws -> [NewsArticle] {
    // withCheckedThrowingContinuation은 블럭 내에서 error를 throw할 수도 있다. 앞에 try await를 붙혀준다.
    try await withCheckedThrowingContinuation { continuation in
      // async function으로 변경이 불가한 메서드를 아래와 같이 사용하되, 마지막 결과를 continuation.resume(returning or throwing)으로 처리한다.
      fetchNews(by: sourceId, url: url) { result in
        switch result {
        case .success(let articles):
          continuation.resume(returning: articles)
        case .failure(let error):
          continuation.resume(throwing: error)
        }
      }
    }
  }

  // async/await 하게 변경이 불가능한 레거시, 3rd party 메서드를 외부에서 내가 구현한 custom function으로 wrapping해서 async/await하게 사용하고 싶다면, continuation을 활용할 수 있다. (+ iOS 13)
  func fetchNews(by sourceId: String, url: URL?, completion: @escaping (Result<[NewsArticle], NetworkError>) -> Void) {
    guard let url = url else {
      completion(.failure(.badUrl))
      return
    }
    
    URLSession.shared.dataTask(with: url) { data, _, error in
      
      guard let data = data, error == nil else {
        completion(.failure(.invalidData))
        return
      }
      
      let newsArticleResponse = try? JSONDecoder().decode(NewsArticleResponse.self, from: data)
      completion(.success(newsArticleResponse?.articles ?? []))
      
    }.resume()
    
  }
  
}
