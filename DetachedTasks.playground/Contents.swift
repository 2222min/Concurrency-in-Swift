// MARK: 43. Detached Tasks
  
import UIKit

func fetchThumbnails() async -> [UIImage] {
  return [UIImage()]
}

func updateUI() async {
  // get thumbnails
  let thumbnails = await fetchThumbnails()
  
  // 일반적인 unstructured Task는 nested expression이 가능하다.
  Task(priority: .background) {
    // 내부의 Task도 priority가 background로 동작한다.
    Task {
      // child task는 parent task의 priority를 그대로 따라가며, parent task가 cancel되면 child task도 cancel이 된다.
      print(Task.currentPriority == .background) // true
    }
  }
  // 하지만, unstructured Task와 달리 detached Task는 가급적(가능한) 사용하지 않는 것이 좋다.
  // detached task는 parent, child task간 상속관계가 형성되지 않아서 수동으로 task cancellation(Task.cancel())을 관리해주어야 한다.
  Task.detached(priority: .background) {
    writeToCache(images: thumbnails)
  }
}

private func writeToCache(images: [UIImage]) {
  // write to cache
}

Task {
  await updateUI()
}

