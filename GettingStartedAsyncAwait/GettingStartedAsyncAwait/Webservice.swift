//
//  Webservice.swift
//  GettingStartedAsyncAwait
//
//  Created by MinKyeongTae on 2022/10/19.
//

import Foundation

// MVVM 상에서, 일반적으로 ViewModel에서 Webservice와 같은 API 요청 객체가 호출되어 사용된다.
class Webservice {
  
  /// 메서드 안에서 try await을 사용하는 경우, 해당 메서드 반환부 앞에 async throws를 명시해 주어야 한다.
  func getDate() async throws -> CurrentDate? {
    guard let url = URL(string: "https://ember-sparkly-rule.glitch.me/current-date") else {
      fatalError("URL is incorrect!")
    }
    
    // async function은 사용 시 await를 앞에 붙혀주어야 한다.
    // (async throws -> try await을 사용해야함)
    let (data, _) = try await URLSession.shared.data(from: url)
    return try? JSONDecoder().decode(CurrentDate.self, from: data)
  }
}
