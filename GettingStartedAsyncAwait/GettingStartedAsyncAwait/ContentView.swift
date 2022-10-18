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
