//
//  ContentView.swift
//  foo
//
//  Created by Mohammad Azam on 7/23/21.
//

// MARK: 65. Actors Example: Bank Account Transfer Funds

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
