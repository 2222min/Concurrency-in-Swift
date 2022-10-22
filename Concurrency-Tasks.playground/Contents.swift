// MARK: 37. Scenario: Calculating APR Using Credit Score
// MARK: 38. Async-let in a Loop
// - async let을 사용하면 단일 async task에서 멈춰있지않고, 다른 task까지 Concurrently하게 동작시킬 수 있다.
// MARK: 39. Async-let in a Loop
// - loop 문과 async let을 함께 사용해보자
// MARK: 40. Cancelling a Task
// - Task.checkCancellation()을 사용하면, 에러가 throwing되어도 이후의 loop task를 멈추지 않고 지속 수행할 수 있다.
// MARK: 42. Unstructured Tasks
// - Unstructured Task의 예는 async methods를 사용하지 못하는 곳에서 사용하는 경우이다. 이때 Task { ... } 블럭 내에서 await, try await 키워드를 붙혀서 async, async throws 메서드를 async하게 사용할 수 있다.

  
import UIKit

enum NetworkError: Error {
  case badUrl
  case decodingError
  case invalidId
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
  print("getAPR calling")

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
/*
Task {
  let apr = try await getAPR(userId: 1)
  print(apr)
}
*/


// * 아래와 같이 loop문에서 async/await을 사용할 수 있는데 알아두어야 할 점
// 1) loop 문이 한번 돌 때, getAPR 내의 async let task들이 concurrent 하게 수행된다.
// 2) task는 concurrent 하게 동작하지만, 결국 feeding 단계에서 suspending이 된다.
// 3) 두개의 task가 전부 끝나고, feeding까지 끝나면, 비로소 loop의 다음 getAPR를 수행한다. (결국 각 getAPR 메서드 내에서 await하는 라인이 있기 때문에 suspend하긴 함. API 요청이 concurrent 할 뿐.)
// => loop를 사용한다고, 모든 getAPR 동작들이 concurrent하게 동작하는것이 아니라는 점을 알아야 한다. (task group을 활용하면 이 또한 concurrent 하게 동작은 가능 함.)
// task group을 살펴 보기 전에 먼저 중요한 요소 중 하나인 cancelling a task 를 알아보자.
/*
let ids = [1, 2, 3, 4, 5]
var invalidIds: [Int] = []
Task {
  for id in ids {
    do {
      // Task.checkCancellation()을 사용하면, 에러가 throwing되어도 이후의 loop task를 멈추지 않고 지속 수행할 수 있다.
      try Task.checkCancellation()
      let apr = try await getAPR(userId: id)
      print(apr)
    } catch {
      print(error)
      invalidIds.append(id)
    }
  }
  
  // error가 발생한 id를 출력 => invalidIdList : 2 4
  print("invalidIdList : \(invalidIds.map { String($0) }.joined(separator: " "))")
}
*/

// MARK: 41. Group Tasks
// async let 을 loop문에서 사용하면 lopp 내 각각의 task 내에서 API 요청은 concurrent 하게 동작하지만 결국 feeding 과정에서 suspend 되고, 이를 기다리는 것을 알 수 있었다.
// => 루프 내 각각의 task를 모두 concurrent하게 동작하고 싶다면? => task groups를 사용하면 된다.

// getAPR은 각각 2개의 API 요청을 concurrent하게 진행함
// [Main Task] -> first Group (getAPR) -> two tasks concurrently
//             -> second Group (getAPR) -> two tasks concurrently
//             -> ..... (getAPR) -> two tasks concurrently

let ids = [1, 2, 3, 4, 5]
var invalidIds: [Int] = []
func getAPRForAllUsers(ids: [Int]) async throws -> [Int: Double] {
  var userAPR: [Int: Double] = [:]
  
  // 1) loop 내 작업들을 concurrent하게 동작하기 위해 for loop 바깥에 try await withThrowingTaskGroup을 사용할 수 있다.
  // - of: group에 추가할 task 결과 타입
  // - body: group task가 수행될 클로져를 정의
  try await withThrowingTaskGroup(of: (Int, Double).self, body: { group in
    for id in ids {
      // 2) group.addTask { ... } 내에 concurrently하게 동작시킬 작업을 정의, 결과는 위에서 정의한 (Int, Double) 튜플타입으로 반환
      group.addTask {
        // 해당 블럭에서는 task 블럭 밖의 값은 변경할 수 없다 getAPR의 결과를 튜플방식으로 group task로 추가한다.
        // loop가 one by one으로 동작이 되기 때문에 dataRacing을 발생할 걱정도 없다.
        // 여기의 작업은 loop 내 각각의 task 중 어떤게 가장 먼저 완료될 지 알 수 없어요. concurrent하게 동작하기 때문에!
        return (id, try await getAPR(userId: id))
      }
    }
    
    // 3) group에 추가된 task들을 async하게 차례대로 작업한다. 여기에서 loop 내부 각 task들은 순차적으로 동작하여 data racing 걱정 없다.
    for try await (id, apr) in group {
      // loop문에서 각 task 결과에 대한 addTask를 수행하ㅗ for try await loop에서 비로소 딕셔너리에 셋팅이 가능했다. (여기는 addTask 블럭 내부가 아니므로, 외부 값 변경이 가능
      userAPR[id] = apr
    }
  })

  return userAPR
}

Task {
  let userAPRs = try await getAPRForAllUsers(ids: ids)
  print(userAPRs)
}
