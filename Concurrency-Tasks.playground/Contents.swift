// MARK: 37. Scenario: Calculating APR Using Credit Score
// MARK: 38. Async-let in a Loop
// async let을 사용하면 단일 async task에서 멈춰있지않고, 다른 task까지 Concurrently하게 동작시킬 수 있다.
  
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

/// 평균 값을 반환
func calculateAPR(creditScores: [CreditScore]) -> Double {
  let sum = creditScores.reduce(0) { next, credit in
    return next + credit.score
  }
  // calculate the APR based on the scores
  return Double((sum / creditScores.count) / 100)
}

func getAPR(userId: Int) async throws -> Double {
  guard let equifaxUrl = Constants.Urls.equifax(userId: userId),
        let experianUrl = Constants.Urls.experian(userId: userId) else {
    throw NetworkError.badUrl
  }
  
  // try await을 사용하였기에 equifaxUrl로부터 결과 값을 수신받을때까지 suspend 된다. ㅠㅠ equifaxUrl 요청이 끝나야 experianUrl로부터 요청을 수행한다..
  // => Concurrently하게 두개 다 요청하는 방법?
  // "Let's work on these two tasks(equifax, experian) concurrently!!"
  // => then, how do we do that?? => async let!
  // MARK: Async-let
  // - async let을 사용하면, async 작업에 대한 reference를 잡고 있는다. 즉시 반환되며, concurrent task로 동작하게 된다.
  // - async let을 붙였다면 뒤에 붙여 사용했던 try await은 명시하지 않아도 된다.
  // * 아래 equifaxData, experianData는 모두 async let으로 정의된다.
  async let (equifaxData, _) = URLSession.shared.data(from: equifaxUrl)
  async let (experianData, _) = URLSession.shared.data(from: experianUrl)
  
  // custom code
  // async throws 메서드로부터 async let 상수를 받은 것이므로, 이를 사용할때는 try await을 사용해야 한다.
  // 아래와 같이 async let 값에 대한 await(try await)을 할때 비로소 suspend 된다! 따라서 async task는 동시에 동작시키고, 이후에 실제 값을 받는 부분에서 기다리는 것 => API 요청은 concurrently하게 하고, 받은 값을 feeding할때만 순차적으로 나눠줌.
  let equifaxCreditScore = try? JSONDecoder().decode(CreditScore.self, from: try await equifaxData)
  let experianCreditScore = try? JSONDecoder().decode(CreditScore.self, from: try await experianData)
  
  guard let equifaxCreditScore = equifaxCreditScore,
        let experianCreditScore = experianCreditScore else {
    throw NetworkError.decodingError
  }
  
  return calculateAPR(creditScores: [equifaxCreditScore, experianCreditScore])
}

Task {
  let apr = try await getAPR(userId: 1)
  print(apr)
}
