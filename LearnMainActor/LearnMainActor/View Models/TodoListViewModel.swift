//
//  TodoListViewModel.swift
//  TodoListViewModel
//
//  Created by Mohammad Azam on 7/24/21.
//

import Foundation

// TodoListViewModel은 @MainActor로 지정되어있으므로 내부에서 main thread에서의 동작을 보장한다.
// @MainActor는 내부 메서드 등에도 지역적으로 사용이 가능하다. 예를들어 메서드에 @MainActor가 붙으면 해당 메서드 동작 내에 한하여 main thread 동작을 보장한다.
@MainActor // => your viewModel must be call on the main thread!!
class TodoListViewModel: ObservableObject {
  
  @Published var todos: [TodoViewModel] = []
  
  func populateTodos() async {
    
    do {
      
      guard let url = URL(string: "https://jsonplaceholder.typicode.com/todos") else {
        throw NetworkError.badUrl
      }
      
      // Other Case. 만약 아래 코드가 Task.detached 블럭 내에 사용되어야 한다면??
      Task.detached { // running on background thread
        print("Thread.isMainThread : \(Thread.isMainThread)") // false, background thread에서 동작!
        let todos = try await Webservice().getAllTodosAsync(url: url)
        // todos는 @Published 멤버이므로 main thread에서 동작해야 함.
        // TodoListViewModel이 @MainActor로 지정되어있을 경우 MainActor.run, DispatchQueue.main 등으로 지역적으로 메인스레드 사용 명시를 할 필요는 없어짐.
        // @MainActor로 명시된 객체 내부에서 아래와 같이 main thread에서 동작을 하지 않는 경우, 컴파일 에러가 발생함
        // -> ex) Property 'todos' isolated to global actor 'MainActor' can not be mutated from a non-isolated context
        // -> 따라서 정상 동작을 위해서는 아래와 같은 main thread가 아닌 곳에서의 변경은 메인스레드 지정을 해주어야 함
        await MainActor.run { // running on main thread
          print("Thread.isMainThread in MainActor.run closure : \(Thread.isMainThread)") // true
          self.todos = todos.map(TodoViewModel.init)
        }
      }
      /*
      Task.detached { // background thread
        // Thread.isMainThread를 통해 현재 동작하는 스레드가 main thread인지 확인 가능하다.
        print("Thread.isMainThread : \(Thread.isMainThread)")
        let todos = try await Webservice().getAllTodosAsync(url: url)
        // MainActor.run { ... } 으로 특정 위치에서 MainActor를 사용하여 main thread에서 동작시킬 수도 있다. 다만 앞에 await을 추가하여 사용한다.
        await MainActor.run {
          print("Thread.isMainThread : \(Thread.isMainThread)")
          // todos 는 main thread에서 동작해야하는 @Published 멤버이다. 따라서 main thread에서 동작 시키는 모습
          self.todos = todos.map(TodoViewModel.init)
        }
      }
      */
    } catch {
      print(error)
    }
  }
}

struct TodoViewModel {
  
  let todo: Todo
  
  var id: Int {
    todo.id
  }
  
  var title: String {
    todo.title
  }
  
  var completed: Bool {
    todo.completed
  }
}
