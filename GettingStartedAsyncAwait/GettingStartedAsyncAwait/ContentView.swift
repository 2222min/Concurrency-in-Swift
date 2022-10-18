//
//  ContentView.swift
//  GettingStartedAsyncAwait
//
//  Created by Mohammad Azam on 7/9/21.
//

import SwiftUI

struct CurrentDate: Decodable, Identifiable {
  // Identifiable 프로토콜을 준수하려면 id를 정의해두어야 함
  let id = UUID()
  let date: String
  
  private enum CodingKeys: String, CodingKey {
    case date = "date"
  }
}

struct ContentView: View {
  /// 메서드 안에서 try await을 사용하는 경우, 해당 메서드 반환부 앞에 async throws를 명시해 주어야 한다.
  private func getDate() async throws -> CurrentDate? {
    guard let url = URL(string: "https://ember-sparkly-rule.glitch.me/current-date") else {
      fatalError("URL is incorrect!")
    }
    
    // async function은 사용 시 await를 앞에 붙혀주어야 한다.
    // (async throws -> try await을 사용해야함)
    let (data, _) = try await URLSession.shared.data(from: url)
    return try? JSONDecoder().decode(CurrentDate.self, from: data)
  }
  
  var body: some View {
    NavigationView {
      List(1...10, id: \.self) { index in
        Text("\(index)")
      }.listStyle(.plain)
      
        .navigationTitle("Dates")
        .navigationBarItems(trailing: Button(action: {
          // button action
        }, label: {
          Image(systemName: "arrow.clockwise.circle")
        }))
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
