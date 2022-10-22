//
//  ContentView.swift
//  foo
//
//  Created by Mohammad Azam on 7/23/21.
//

// MARK: 65. Actors Example: Bank Account Transfer Funds
// MARK: 66. Understanding nonisolated Keyword in Swift
// actor 내에서 nonisolated keyword가 붙은 메서드는
// - 내부에 변경코드를 작성할 수 없다. (변경하려고 하면 컴파일 에러가 발생한다.)
// - 외부에서 사용할때 Task 블럭 내에 async/await 방식으로 사용할 필요가 없다. data racing 문제가 발생할 여지가 없기 때문이다.

import SwiftUI

enum BankError: Error {
  case insufficientFunds(Double)
}

// 이번에도 BankAccount를 actor로 선언했다. 한번에 한번씩만 접근이 가능하다.
// concurrent task로 공통의 자원을 병행적으로 읽거나 쓰는 문제인 data racing(race condition)을 방지해주며 내부의 메서드는 async/await 하게 동작해야 한다.
actor BankAccount {
  
  let accountNumber: Int
  var balance: Double
  
  init(accountNumber: Int, balance: Double) {
    self.accountNumber = accountNumber
    self.balance = balance
  }
  
  // getCurrentAPR은 고정된 값만 반환하지 내부에서 변경이 일어나는 메서드는 아니다.
  // 따라서 Data racing이 발생할 일이 없다. 이런 경우에는 앞에 nonisolated를 붙혀서 actor가 아닌 struct, class 메서드처럼 호출해서 사용할 수 있다.
  // => nonisolated func : "야 이거 race condition 발생할 일 없는 놈이야 async/await call방식을 취할 필요가 없어!"
  nonisolated func getCurrentAPR() -> Double {
    // nonisolated func은 내부에 변경 코드를 허용하지 않는다.
    // * 경고 내용 : Actor-isolated property 'balance' can not be mutated from a non-isolated context
    // balance += 10
    return 0.2
  }
  
  // 반환부 앞에 async를 붙혀도 안붙혀도 외부에서는 await을 붙혀서 사용해야한다. actor 메서드니까.
  func deposit(_ amount: Double) {
    balance += amount
  }
  
  func transfer(amount: Double, to other: BankAccount) async throws {
    if amount > balance {
      throw BankError.insufficientFunds(amount)
    }
    
    balance -= amount
    // other는 actor(BankAccount)이다. 따라서 deposit 메서드 동작을 위해 await를 붙인다.
    await other.deposit(amount)
    // other의 모든 멤버가 await으로 사용되는건 아니다. accountNumber는 상수이므로 await 없이도 동작이 가능하다.
    print(other.accountNumber)
    print("Current Account: \(balance), Other Account: \(await other.balance)")
  }
}

struct ContentView: View {
  
  var body: some View {
    Button {
      
      let bankAccount = BankAccount(accountNumber: 123, balance: 500)
      let otherAccount = BankAccount(accountNumber: 456, balance: 100)
      
      // getCurrentAPR()은 actor method임에도 nonisolated func이므로, async/await하게 사용하지 않아도 된다.
      let _ = bankAccount.getCurrentAPR()
      
      DispatchQueue.concurrentPerform(iterations: 100) { _ in
        Task {
          try? await bankAccount.transfer(amount: 300, to: otherAccount)
        }
      }
    } label: {
      Text("Transfer")
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
