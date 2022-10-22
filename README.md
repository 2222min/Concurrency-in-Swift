# Concurrency-in-Swift
Let's learn about Concurrency in Swift with udemy lecture.



## Concurrency

Concurrency란, 동시에 다수의 작업을 진행하는 것.

- serial하게 동작하는 Main thread에서 UI Event, Downloading Images task등을 모두 동작시킨다면?… 멈춤현상이 발생할 수 있음 => 매우 나쁜 user experience를 만들 수 있음

- 작업 특성에 맞게 각기 thread에서 동작하도록 할 수 있음 (ex) downloading images를 main thread 대신 background thread에서 동작)

- - DispatchQueue.global().async { let _ = try? Data(contentOf: imageURL }

- 이후 main thread에서 UI를 업데이트 시킬 수 있음

- - DispatchQueue.main.async { // update the ui }

- 이처럼 GCD를 이용해 상황에 따라 main, background thread에서 비동기로 작업을 수행할 수 있음



## GCD



## Main Queue (serial queue)

- Main thread는 serial queue로 동작한다. 하나씩 순차적으로 작업이 진행 된다. 하나의 작업이 진행되는동안 다른 이벤트는 처리할 수가 없다.



## Global Queue (Concurrent)

- Global Queue는 QoS(Quality of Service)를 설정할 수 있다.
  - User Interactive
    - animation, event handling, updating user interface 등 사용자와 직업 상호작용하는 작업
    - 메인 스레드에서 처리하면 많은 로드가 걸릴 수 있는 작업들은 userInteractive에서 처리해서 바로 동작하는 것처럼 보이게 할 수 있음
  - User Initiated
    - 저장된 문서 열기 등 클릭 시 작업을 수행할 때 처럼 즉각적인 결과가 필요한 작업, 
    - userInteractive보다는 조금 오래걸릴 수 있지만 유저가 이를 인지하고 있음
  - Utility
    - 데이터 다운로드 처럼 보통 progress bar와 함께 길게 실행되는 작업
  - Background
    - 동기화 및 백업 처럼 유저가 직접적으로 인지할 필요성이 적은 작업
  - Default
    - 일반적인 작업
  - Unspecified
    - 명확히 지정된 QoS가 없음



### Creating a global Background Queue

~~~swift
DispatchQueue.global().async {
  // download the image
  
  // refresh the UI (background queue 에서 UI를 업데이트 하면 안됨)
}

DispatchQueue.global().async {
  // download the image
  DispatchQueue.main.async {
    // refresh the UI (UI 관련 작업은 Main thread에서 동작시켜야 함)
  }
}
~~~





### Creating a my Serial Queue

~~~swift
// Serial Queue는 Concurrent Queue와 달리 순차적으로 작업이 진행되므로 작업 순서가 보장된다.
let queue = DispatchQueue(label: "SerialQueue")

queue.async {
  // this task is executed first
}

queue.async {
  // this task is executed second
}
~~~



### Creating a my Concurrent Queue

~~~swift
// Concurrent Queue는 Serial Queue와 달리 작업 순서가 보장되지 않는다.
let queue = DispatchQueue(label: "ConcurrentQueue", attributes: .concurrent)

queue.async {
  // ...
}

queue.async {
  // ...
}

// Tasks will start in the order they are added but they can finish in any order (시작은 순서대로 진행되지만, 작업이 종료되는 순서는 보장되지 않음)
~~~



### Why is the Design Patterns important?

- Best practices, 실용적인 구조를 만들기 위한 노력

- Relationships between classes and objects, 클래스 등의 객체 간의 관계를 정의
- Speed up development, 개발 속도 향상
- Programming independent, 프로그래밍 독립성
- Flexible, reusable and maintainable, 융통적으로, 재사용가능하게, 유지보수가 더욱 쉽게 만들기 위해



## MVVM

- Model, View, ViewModel로 구성되는 디자인패턴 기법
- ViewModel이 비즈니스로직을 가져가게 되며 MVC의 Massive ViewController를 해결하고 Testability의 어려움을 해소할 수 있다.
- ViewModel이 주요 비즈니스로직을 갖고 있다. ViewModel의 변화를 View는 감지하고 그에 맞게 변화한다.
- View는 이벤트를 ViewModel에 전달하고, ViewModel은 이벤트에 맞는 비즈니스 로직을 수행한다.
- ViewModel에서는 Constant값이나 복잡해지는 비즈니스 모델 등은 Model로 분리하여 관리된다. (View, Model은 서로 직접적으로 소통할일이 없다.)
- why MVVM? : view로부터 들어오는 value에 대한 validation을 ViewModel에서 할 수 있다. ViewModel은 View 분리되어있기 때문에 View에 영향을 미치지 않고 ViewModel에 독립적인 테스트코드를 작성해서 테스트하기 용이하다.

#### MVVM에서의 Web API 동작

- View -> Web service -> API 요청을 하는 것은 가능은 하지만 결코 좋은 로직이 아니다.
- MVVM 패턴에서는 View - 이벤트 -> ViewModel -> Web service / Client -> API 요청을 할 수 있다.



## What is Continuation?

- continuation을 사용하면 기존의 callback closure가 있는 legacy 메서드를 그대로 유지하고 wrapping해서 외부에서 콜벡 결과에 따른 async await 처리를 할 수 있도록 도와준다.

- callback closure를 사용하거나 여러 사유로 변형하기 힘든 third-party, legacy 메서드를 wrapping해서 외부에서 async await 방식으로 처리하고자 할때 유용하게 사용할 수 있다.

- withCheckedContinuation 사용 예시

~~~ swift
func getPosts() async throws -> [Post] {
  // error를 throw할 일이 없으면 withCheckedContinuation을 사용
  return await withCheckedContinuation { continuation in
    // continuation을 활용하면 callback closure가 있는 getPosts 메서드를 외부에서는 async await 방식으로 처리할 수 있도록 할 수 있다.
		getPosts { posts in
			continuation.resume(returning: posts)
		}
	}
}
~~~



## Section 7: Project  Time: News App

News App 초기상태는 async await, continiuation 등의 Concurrency를 사용하지 않은 버전입니다. @escaping closure 등으로 콜백 이벤트를 처리할 수도 있지만, 콜백 지옥을 야기하거나, 콜백 클로져 실행 후 특정 분기 return을 놓치면 비정상 동작을 할 수 있는 단점이 있습니다.

이제 이 앱에 async/await, continuation, mainActor 등의 개념을 적용해 봅시다!

async/await, continuation, @MainActor 등의 개념들은 URLSession, Notification, HealthKit, CoreData 등 다양한 곳에서 활용 가능하다



## Section 8: Understanding Structured Concurrency in Swift

##### 👩🏻‍💻 learning point : Structured Concurrency, Async Let, Task Group, Unstructured Tasks, Detached Tasks, Task Cancellation

### async-let Tasks

~~~swift
// try await을 사용하였기에 equifaxUrl로부터 결과 값을 수신받을때까지 suspend 된다. ㅠㅠ equifaxUrl 요청이 끝나야 experianUrl로부터 요청을 수행한다..
  // => Concurrently하게 두개 다 요청하는 방법?
  // "Let's work on these two tasks(equifax, experian) concurrently!!"
  // => then, how do we do that?? => async let!
  // MARK: Async-let
  // - async let을 사용하면, async 작업에 대한 reference를 잡고 있는다. 즉시 반환되며, concurrent task로 동작하게 된다.
  // - async let을 붙였다면 뒤에 붙여 사용했던 try await은 명시하지 않아도 된다.(ex) 아래 코드의 URLSession 앞에 try await를 명시할 의무가 없음
  // * 아래 equifaxData, experianData는 모두 async let으로 정의된다.
  async let (equifaxData, _) = URLSession.shared.data(from: equifaxUrl)
  async let (experianData, _) = URLSession.shared.data(from: experianUrl)
  
  // custom code
  // async throws 메서드로부터 async let 상수를 받은 것이므로, 이를 사용할때는 try await을 사용해야 한다.
  // 아래와 같이 async let 값에 대한 await(try await)을 할때 비로소 suspend 된다! 따라서 async task는 동시에 동작시키고, 이후에 실제 값을 받는 부분에서 기다리는 것 => API 요청은 concurrently하게 하고, 받은 값을 feeding할때만 순차적으로 나눠줌.
  let equifaxCreditScore = try? JSONDecoder().decode(CreditScore.self, from: try await equifaxData)
  let experianCreditScore = try? JSONDecoder().decode(CreditScore.self, from: try await experianData)
~~~



### async-let Tasks in loop (언제 Concurrent하게, Serial하게 동작하는가)

~~~ swift
let ids = [1, 2, 3, 4, 5]
Task {
  for id in ids {
    // * 아래와 같이 loop문에서 async/await을 사용할 수 있는데 알아두어야 할 점
    // 1) loop 문이 한번 돌 때, getAPR 내의 async let task들이 concurrent 하게 수행된다.
    // 2) task는 concurrent 하게 동작하지만, 결국 feeding 단계에서 suspending이 된다.
    // 3) 두개의 task가 전부 끝나고, feeding까지 끝나면, 비로소 loop의 다음 getAPR를 수행한다. (결국 각 getAPR 메서드 내에서 await하는 라인이 있기 때문에 suspend하긴 함. API 요청이 concurrent 할 뿐.)
    // => loop를 사용한다고, 모든 getAPR 동작들이 concurrent하게 동작하는것이 아니라는 점을 알아야 한다. (task group을 활용하면 이 또한 concurrent 하게 동작은 가능 함.)
    // task group을 살펴 보기 전에 먼저 중요한 요소 중 하나인 cancelling a task 를 알아보자.
    let apr = try await getAPR(userId: id)
    print(apr)
  }
}
~~~



### Cancelling a Task, Task.checkCancellation()

~~~swift
let ids = [1, 2, 3, 4, 5]
var invalidIds: [Int] = []
Task {
  for id in ids {
    do {
      // Task.checkCancellation()을 사용하면, 에러가 throwing되어도 이후의 loop task를 멈추지 않고 지속 수행할 수 있다.
      try Task.checkCancellation()
      let apr = try await getAPR(userId: id)
      print(apr)
    } catch {
      print(error)
      invalidIds.append(id)
    }
  }
  
  // error가 발생한 id를 출력 => invalidIdList : 2 4
  print("invalidIdList : \(invalidIds.map { String($0) }.joined(separator: " "))")
}
~~~



### Group Tasks

##### - withTaskGroup, withThrowingTaskGroup (group.addTask { ... })

~~~swift
// MARK: 41. Group Tasks
// async let 을 loop문에서 사용하면 lopp 내 각각의 task 내에서 API 요청은 concurrent 하게 동작하지만 결국 feeding 과정에서 suspend 되고, 이를 기다리는 것을 알 수 있었다.
// => 루프 내 각각의 task를 모두 concurrent하게 동작하고 싶다면? => task groups를 사용하면 된다.

// getAPR은 각각 2개의 API 요청을 concurrent하게 진행함
// [Main Task] -> first Group (getAPR) -> two tasks concurrently
//             -> second Group (getAPR) -> two tasks concurrently
//             -> ..... (getAPR) -> two tasks concurrently

let ids = [1, 2, 3, 4, 5]
var invalidIds: [Int] = []
func getAPRForAllUsers(ids: [Int]) async throws -> [Int: Double] {
  var userAPR: [Int: Double] = [:]
  
  // 1) loop 내 작업들을 concurrent하게 동작하기 위해 for loop 바깥에 try await withThrowingTaskGroup을 사용할 수 있다.
  // - of: group에 추가할 task 결과 타입
  // - body: group task가 수행될 클로져를 정의
  try await withThrowingTaskGroup(of: (Int, Double).self, body: { group in
    for id in ids {
      // 2) group.addTask { ... } 내에 concurrently하게 동작시킬 작업을 정의, 결과는 위에서 정의한 (Int, Double) 튜플타입으로 반환
      group.addTask {
        // 해당 블럭에서는 task 블럭 밖의 값은 변경할 수 없다 getAPR의 결과를 튜플방식으로 group task로 추가한다.
        // loop가 one by one으로 동작이 되기 때문에 dataRacing을 발생할 걱정도 없다.
        // 여기의 작업은 loop 내 각각의 task 중 어떤게 가장 먼저 완료될 지 알 수 없어요. concurrent하게 동작하기 때문에!
        return (id, try await getAPR(userId: id))
      }
    }
    
    // 3) group에 추가된 task들을 async하게 차례대로 작업한다. 여기에서 loop 내부 각 task들은 순차적으로 동작하여 data racing 걱정 없다.
    for try await (id, apr) in group {
      // loop문에서 각 task 결과에 대한 addTask를 수행하ㅗ for try await loop에서 비로소 딕셔너리에 셋팅이 가능했다. (여기는 addTask 블럭 내부가 아니므로, 외부 값 변경이 가능
      userAPR[id] = apr
    }
  })

  return userAPR
}

Task {
  let userAPRs = try await getAPRForAllUsers(ids: ids)
  print(userAPRs)
}
~~~



