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
  
  @State private var currentDates: [CurrentDate] = []
  
  // await, try await을 내부에서 사용하지만, 더이상 error를 throw하지 않을 경우, 반환부에 async만 명시해주면 된다.
  private func populateDates() async {
    do {
      guard let currentDate = try await Webservice().getDate() else {
        return
      }
      self.currentDates.append(currentDate)
    } catch {
      print(error)
    }
  }
  
  var body: some View {
    NavigationView {
      // currentDates의 Element들은 Identifiable 프로토콜을 준수하므로, List에서 id를 별도로 지정해줄 필요가 없다.
      List(currentDates) { currentDate in
        Text("\(currentDate.date)")
      }.listStyle(.plain)
      
        .navigationTitle("Dates")
        .navigationBarItems(trailing: Button(action: {
          // button action
          // async closure is deprecated now. try to use Task closure block instead.
          Task {
            await populateDates()
          }
        }, label: {
          Image(systemName: "arrow.clockwise.circle")
        }))
        .task {
          // 아래 주석처리한 코드랑 동일한 동작(onAppear 시기에 Task block 동작 실행)을 실행할 수 있다.
          await populateDates()
        }
//      .onAppear {
//        Task {
//          // async function을 호출하려면 await을 앞에 붙히고, Task block내에서 실행해야 한다.
//          await populateDates()
//        }
//      }
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
