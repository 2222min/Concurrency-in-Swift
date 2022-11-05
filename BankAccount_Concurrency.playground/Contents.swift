// MARK: - Section 11. Concurrent Programming: Problem and Solutions
// MARK: 58. Problem: Bank Account Withdraw (은행 계좌 출금 문제)
// MARK: 59. Solution 1: Bank Account Withdraw Using Serial Queue
// MARK: 60. Solution 2: Bank Account Withdraw Using Locks(NSLock)
// * reference, Avoiding race conditions in Swift
//   https://medium.com/swiftcairo/avoiding-race-conditions-in-swift-9ccef0ec0b26
  
import UIKit

class BankAccount {
  var balance: Double
  let lock = NSLock()
  
  init(balance: Double) {
    self.balance = balance
  }
  
  func withdraw(_ amount: Double) {
    // NSLock을 통한 locking을 하면, 동시적 작업으로 인해 잔고가 minus가 되는것을 방지해준다. (하나의 스레드에 하나의 동작씩만 실행되도록 보장)
    // lock() 사용 시, 반드시 unlock()을 직접 지정해주어야 하는 단점이 있다. 만약 까먹고 unlock()을 처리하지 않으면, 해당 스레드의 다음 작업이 매우 지연될 수 있다.
    // -> 차선책으로 actor를 사용할 수 있다.
    lock.lock()
    if balance >= amount {
      let processingTime = UInt32.random(in: 0...3) // 처리 시간은 1 ~ 3초로 동작
      print("[withdraw] Processing for \(amount) \(processingTime) seconds")
      sleep(processingTime) // 3초 후 amount만큼 출금을 시도
      print("withdrawing \(amount) from account")
      balance -= amount
      print("Balance is \(balance)")
    }
    lock.unlock()
  }
}

// Q. 만약 동시에 많은 요청이 오게 된다면??

let bankAccount = BankAccount(balance: 500)
// 작업을 concurrent하게 하지않고, serial하게 동작하면, 동시에 작업이 수행되는 일이 없기에 잔고가 -가 발생하지는 않는다.
let queue = DispatchQueue(label: "Serial Queue")

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

// serial 하게 실행하거나, NSLock()의 lock(), unlock()을 사용 시, 잔고가 -가 되는 문제는 해결이 됨.
// -> 또다른 해결방법 => Actor를 Section 12에서 알아보자!!
/*
 [withdraw] Processing for 300.0 2 seconds
 withdrawing 300.0 from account
 Balance is 200.0
 // 두번째 작업은 실행되지 않음. 출금이 불가능(출금할 amount가 잔고보다 큼)하기에
*/
