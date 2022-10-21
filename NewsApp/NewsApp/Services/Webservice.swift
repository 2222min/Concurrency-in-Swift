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
