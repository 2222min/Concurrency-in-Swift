//
//  ContentView.swift
//  LearnActors
//
//  Created by Mohammad Azam on 7/19/21.
//

import SwiftUI
// @MainActor를 사용하여 해당 객체 내부 동작이 main thread에서 동작함을 보장한다.
@MainActor
class BankAccountViewModel: ObservableObject {
  
  private var bankAccount: BankAccount
  // ObservableObject(View에서는 @StateObject, @ObservedObject 등으로 사용) 내의 @Published 변수들은 변경이 될때 View의 변화에 영향을 줄 수 있으므로 main thread에서 변화를 시켜야 한다.
  @Published var currentBalance: Double?
  @Published var transactions: [String] = []
  
  init(balance: Double) {
    bankAccount = BankAccount(balance: balance)
  }
  
  func withdraw(_ amount: Double) async {
    // actor의 method인 withdraw() 사용을 위해 await를 사용한다. getBalance(), transactions() 또한 마찬가지.
    await bankAccount.withdraw(amount)
    
    self.currentBalance =  await self.bankAccount.getBalance()
    self.transactions = await self.bankAccount.transactions
  }
  
}

actor BankAccount {
  
  private(set) var balance: Double
  private(set) var transactions: [String] = []
  
  init(balance: Double) {
    self.balance = balance
  }
  
  func getBalance() -> Double {
    return balance
  }
  
  func withdraw(_ amount: Double) {
    
    if balance >= amount {
      
      let processingTime = UInt32.random(in: 0...3)
      print("[Withdraw] Processing for \(amount) \(processingTime) seconds")
      transactions.append("[Withdraw] Processing for \(amount) \(processingTime) seconds")
      sleep(processingTime)
      print("Withdrawing \(amount) from account")
      transactions.append("Withdrawing \(amount) from account")
      
      self.balance -= amount
      
      print("Balance is \(balance)")
      transactions.append("Balance is \(balance)")
      
    }
  }
  
}


struct ContentView: View {
  
  @StateObject private var bankAccountVM = BankAccountViewModel(balance: 500)
  let queue = DispatchQueue(label: "ConcurrentQueue", attributes: .concurrent)
  
  var body: some View {
    VStack {
      Button("Withdraw") {
        
        // Task.detached를 아래와 같이 사용하면 두개의 Task.detached { ... } 동작을 concurrently 동작시킬 수 있다.
        // 그렇기 때문에 아래 두개 중 어느동작이 먼저 처리될 지 알수가 없다.. 최소한 동시 실행되어 잔고가 -가 될 일은 없다는거
        Task.detached {
          await bankAccountVM.withdraw(200)
        }
        
        Task.detached  {
          // actor를 사용하였기에, 500 -> 300이 된상태에서 아래 메서드가 실행되며, 출금할 잔고가 없으므로 그대로 300으로 남는다.
          // => 이처럼 외부적으로 concurrently 동작하더라도, actor의 프로퍼티, 메서드 접근은 동시에 접근이 되지 않는다.
          await bankAccountVM.withdraw(500)
        }
      }
      
      Text("\(bankAccountVM.currentBalance ?? 0.0)")
      
      List(bankAccountVM.transactions, id: \.self) { transaction in
        Text(transaction)
      }
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
