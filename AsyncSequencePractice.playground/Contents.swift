
import UIKit

enum AsyncSequenceError: Error {
  case invalidNumber
  
  var message: String {
    switch self {
    case .invalidNumber:
      return "ㅠ.ㅠ"
    }
  }
}

// reference : https://zeddios.tistory.com/1339
struct Counter: AsyncSequence, AsyncIteratorProtocol {
  typealias Element = Int
  var index = 0
  
  mutating func next() async -> Element? {
    defer { index += 1 }
    return index
  }
  
  func makeAsyncIterator() -> Counter {
    self
  }
}

let counter = Counter()
Task {
  for  await value in counter {
    if value >= 10 { break }
    print("now value : \(value)")
  }
}
