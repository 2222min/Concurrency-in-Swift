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
