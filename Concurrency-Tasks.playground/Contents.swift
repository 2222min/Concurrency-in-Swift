// MARK: 37. Scenario: Calculating APR Using Credit Score
  
import UIKit

enum NetworkError: Error {
  case badUrl
  case decodingError
}

struct CreditScore: Decodable {
  let score: Int
}

struct Constants {
  struct Urls {
    static func equifax(userId: Int) -> URL? {
      return URL(string: "https://ember-sparkly-rule.glitch.me/equifax/credit-score/\(userId)")
    }
    
    static func experian(userId: Int) -> URL? {
      return URL(string: "https://ember-sparkly-rule.glitch.me/experian/credit-score/\(userId)")
    }
  }
}

func getAPR(userId: Int) async throws -> Double {
  guard let equifaxUrl = Constants.Urls.equifax(userId: userId),
        let experianUrl = Constants.Urls.experian(userId: userId) else {
    throw NetworkError.badUrl
  }
  
  // try await을 사용하였기에 equifaxUrl로부터 결과 값을 수신받을때까지 suspend 된다. ㅠㅠ equifaxUrl 요청이 끝나야 experianUrl로부터 요청을 수행한다..
  // => Concurrently하게 두개 다 요청하는 방법?
  // "Let's work on these two tasks(equifax, experian) concurrently!!"
  // => then, how do we do that??
  let (equifaxData, _) = try await URLSession.shared.data(from: equifaxUrl)
  let (experianData, _) = try await URLSession.shared.data(from: experianUrl)
  
  return 0.0
}
