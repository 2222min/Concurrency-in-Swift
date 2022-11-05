// MARK: - Section 11. Concurrent Programming: Problem and Solutions
// MARK: 58. Problem: Bank Account Withdraw (은행 계좌 출금 문제)
  
import UIKit

class BankAccount {
  var balance: Double
  
  init(balance: Double) {
    self.balance = balance
  }
  
  func withdraw(_ amount: Double) {
    if balance >= amount {
      let processingTime = UInt32.random(in: 0...3) // 처리 시간은 1 ~ 3초로 동작
      print("[withdraw] Processing for \(amount) \(processingTime) seconds")
      sleep(processingTime) // 3초 후 amount만큼 출금을 시도
      print("withdrawing \(amount) from account")
      balance -= amount
      print("Balance is \(balance)")
    }
  }
}

// Q. 만약 동시에 많은 요청이 오게 된다면??

let bankAccount = BankAccount(balance: 500)
let queue = DispatchQueue(label: "ConcurrentQueue", attributes: .concurrent)

queue.async {
  bankAccount.withdraw(300)
}

queue.async {
  bankAccount.withdraw(500)
}

// concurrent 하게 다수의 출금 요청을 실행 시 잔고가 -가 되는 상황이 발생!!
/*
 [withdraw] Processing for 300.0 2 seconds
 [withdraw] Processing for 500.0 3 seconds
 withdrawing 300.0 from account
 Balance is 200.0
 withdrawing 500.0 from account
 Balance is -300.0
*/
