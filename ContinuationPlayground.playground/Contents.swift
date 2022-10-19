// MARK: 28. Implementing a Get All Posts Callback Function Using Result Type
// First, let's implement the function with escaping callback closure the first to use continuation
  
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

getPosts { result in
  switch result {
  case .success(let posts):
    print(posts)
  case .failure(let error):
    print(error)
  }
}
