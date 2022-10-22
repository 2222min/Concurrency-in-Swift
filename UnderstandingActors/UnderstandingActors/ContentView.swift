//
//  ContentView.swift
//  UnderstandingActors
//
//  Created by MinKyeongTae on 2022/10/22.
//

// MARK: - Section 12: What are Actors?
// MARK: 63. Understanding Actors

import SwiftUI

// 1) class로 사용한다면
/*
class Counter {
  var value: Int = 0
  
  func increment() -> Int {
    value += 1
    return value
  }
}
// => concurrently 동작 시, 출력 순서가 보장되지 않음
*/

/*
// 2) struct로 사용한다면
struct Counter {
  var value: Int = 0
  
  mutating func increment() -> Int {
    value += 1
    return value
  }
}
// => concurrently 동작 시, 출력 순서가 보장되지 않음
// 값 복사해서 호출할 경우, 1이 무수히 출력 됨..
*/

// 3) class, struct 대신 actor를 사용해보기
// actor는 단 하나의 스레드에서만 동작하도록 보장해준다. 따라서 data racing 문제가 해결된다.
actor Counter {
  var value: Int = 0
  // 하나의 스레드에서 한번에 하나의 동작만, 동작이 완료되면 suspended 다음 동작이 수행되므로 출력 순서가 보장
  // actor 내의 methods는 await를 붙혀서 호출, 두개 이상의 스레드에서 한번에 동작하지 않음
  func increment() -> Int {
    value += 1
    return value
  }
}

struct ContentView: View {
    var body: some View {
      Button {
        let counter = Counter()
        // 1) 만약 concurrent 하게 동시에 increment가 발생한다면?
        // 100까지 증가하면 출되는 것을 기대하고 아래코드를 실행한다면? => 카운팅 뒤죽박죽 순서로 출력이 됨... => concurrently 하게 동작하므로, 순서가 보장되지 않는다.
        DispatchQueue.concurrentPerform(iterations: 100) { _ in
          // 2) 아래처럼 struct상태 counter의 copy를 생성하고, increment()를 호출하면? -> 전부 zero에서 시작하므로 1이 무수하게 출력됨.
          // var counter = counter // struct를 사용하는 경우
          // print(counter.increment())
          // 3) actor를 사용해보자.
          Task {
            // await, try await 등은 Task 블럭 내부, .task viewModifier 내부 등에서 사용해야한다.
            // => increment() 출력 결과, 순서가 보장된다!
            print(await counter.increment())
          }
        }
      } label: {
        Text("Increment")
      }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
