
import SwiftUI

enum MyError: Error {
  case invalidCount
}

func countdown() async throws {
  let counter = AsyncThrowingStream<String, Error> { continuation in
    var countdown = 3
    Timer.scheduledTimer(
      withTimeInterval: 1.0,
      repeats: true
    ) { timer in
      guard countdown > 0 else {
        timer.invalidate()
        // .failure 이벤트도 전달하고 싶다면, AsyncStream 대신, AsyncThrowingStream을 사용해야함
        continuation.yield(with: .success("\(Date()) bye bye!"))
        // countdown이 모두 끝나면, continuation 종료
        return
      }
      
      // 특정 상황에 에러를 던지고 싶을때 .failure 이벤트를 보내면 AsyncSequence에 에러이벤트가 제공된다.
      if countdown == 1 {
        continuation.yield(with: .failure(MyError.invalidCount))
      }
      // countdown 할때마다 yield로 AsyncStream에 제공할 값을 전달
      continuation.yield("\(Date()) countdown : \(countdown)")
      // Timer에 의해 1초마다 countdown이 1씩 감소, 0이되면 Timer 중지
      countdown -= 1
    }
  }
  // AsyncThrowingStream인 counter를 순회하며 try await 작업을 진행하고 있다.
  for try await count in counter {
    print(count)
  }
}

func runAsyncThrowingStreamTask() {
  // 마지막 Task { ... } 블럭 사용 부에서는 메서드 반환부 앞에 async, async throws를 붙히지 않는다.
  Task {
    do {
      try await countdown()
    } catch {
      // error를 throw하지 않는 경우, 메서드에 throws 키워드 설정 안해도 됨
      print(error.localizedDescription)
    }
  }
}

runAsyncThrowingStreamTask()
