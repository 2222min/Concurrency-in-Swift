
// MARK: 56. Adapting Existing Callbacks or Handlers to AsyncSequence Using AsyncStream

import UIKit

class BitcoinPriceMonitor {
  
  var price: Double = 0.0
  var timer: Timer?
  var priceHandler: (Double) -> Void = { _ in }
  
  // Timer 설정에 #selector로 지정되기 위해서는 @objc를 붙여서 Objective-C runtime에서 소통가능하도록 해주어야 합니다.
  @objc func getPrice() {
    priceHandler(Double.random(in: 20000...40000))
  }
  
  func startUpdating() {
    timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(getPrice), userInfo: nil, repeats: true)
  }
  
  func stopUpdating() {
    timer?.invalidate()
  }
}

/*
let bitcoinPriceMonitor = BitcoinPriceMonitor()
// 아래와 같은 타이머 값을 수신하는 클로져를 AsyncStream화해서 Async/Await 하게 사용할 수 있을까? -> 가능함.
bitcoinPriceMonitor.priceHandler = {
  print($0)
}

bitcoinPriceMonitor.startUpdating()
*/

let bitcoinPriceStream = AsyncStream(Double.self) { continuation in
  let bitcoinPriceMonitor = BitcoinPriceMonitor()
  bitcoinPriceMonitor.priceHandler = {
    // AsyncSequence에 제공될 값을 전달할때 yield를 사용
    continuation.yield($0)
  }
  // continuation을 통해 onTermination callback 클로져를 설정 가능
  // continuation.onTermination = { _ in }
  bitcoinPriceMonitor.startUpdating()
}

Task {
  // AsyncStream을 사용할때 장점
  // 1) 콜백 스트림들을 AsyncSequene로 변환해서 사용할 수 있는데 이때 기존 Sequence를 채택한 애들이 사용가능한 다양한 연산자를 함께 활용 가능하다.
  // 2) Async/Await하게 동시성 프로그래밍을 할 수 있다.
  for await bitcoinPrice in bitcoinPriceStream {
    print(bitcoinPrice)
  }
}
