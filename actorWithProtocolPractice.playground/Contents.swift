
import UIKit
import SwiftUI

protocol Human {
  associatedtype Food
  var food: Food { get set }
  
  func eat(food: Food)
}

class Baby: Human {
  // 아래처럼 Food associatedtype의 타입을 정의할수도 있지만 관련 멤버들의 타입을 통해 타입을 추론하는 방식으로 사용도 됨
  // Human protocol의 필수 구현 메서드, eat에서 food 타입인 Food를 String타입으로 사용했기에 이를 타입 추론하여 Food 타입을 String으로 인식함
  // typealias Food = String
  var food: String
  
  init(food: String) {
    self.food = food
  }

  func eat(food: String) {
    print(food)
  }
}

protocol ActorMan {
  associatedtype Food
  var food: Food { get }
}

actor ActMan: ActorMan {
  typealias Food = String
  // food는 data racing, race condition이 발생할 가능성이 전혀 없는 놈이라 nonisolated 로 선언해서 외부에서는 async/await 방식으로 사용 안해도 된다.
  // constant는 상수이므로, actor 멤버이지만 nonisolated 명시 안해도 외부에서 await으로 사용할 필요가 없음
  let constant = "hahhaa"
  // 변경 가능성이 없는 아래와 같은 getter 프로퍼티는 nonisolated 명시를 통해 외부에서 await 하게 사용할 필요 없도록 할 수 있음
  nonisolated var food: String {
    return "apple"
  }
  
  init() {}
}

let baby = Baby(food: "apple")
baby.eat(food: "human")

let actorMan = ActMan()
print(actorMan.constant)
print(actorMan.food)

/*
import PlaygroundSupport

class MyViewController : UIViewController {
    override func loadView() {
        let view = UIView()
        view.backgroundColor = .white

        let label = UILabel()
        label.frame = CGRect(x: 150, y: 200, width: 200, height: 20)
        label.text = "Hello World!"
        label.textColor = .black
        
        view.addSubview(label)
        self.view = view
    }
}
// Present the view controller in the Live View window
PlaygroundPage.current.liveView = MyViewController()
*/
