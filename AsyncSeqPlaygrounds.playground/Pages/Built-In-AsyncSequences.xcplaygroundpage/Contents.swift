
// MARK: 55. Built-In AsyncSequences in iOS Framework
// - AsyncSequences를 사용하는 다양한 framework 내장 기능(Built-In-Functions)들이 있다.
// ex) 로컬파일, URL의 byte 읽을때, NotificationCenter로부터 특정 이벤트 처리할때 등...

import Foundation
import UIKit
import _Concurrency

// txt파일을 불러와서 line을 출력
let paths = Bundle.main.paths(forResourcesOfType: "txt", inDirectory: nil)
let fileHandle = FileHandle(forReadingAtPath: paths[0])
/*
Task {
  for try await line in fileHandle!.bytes {
    // print async bytes
    print(line)
  }
}
*/

// 이처럼 URL, local data에 대한 byte를 읽을때도 AsyncSequence를 활용할 수 있다.
let url = URL(string: "https://www.google.com")!
Task {
  let (bytes, _) = try await URLSession.shared.bytes(from: url)
  for try await byte in bytes {
    print(byte)
  }
}

Task {
  let center = NotificationCenter.default
  await center.notifications(named: UIApplication.didEnterBackgroundNotification).first {
    guard let key = $0.userInfo?["key"] as? String else { return false }
    return key == "SomeValue"
  }
}
