//
//  ContentView.swift
//  GettingStartedAsyncAwait
//
//  Created by Mohammad Azam on 7/9/21.
//

import SwiftUI

struct ContentView: View {
  // @ObservedObject 대신 @StateObject를 사용하면, ObservableObject 객체 인스턴스를 holding하고, 상위 View 업데이트에 의해 해당 뷰가 초기화되어도 기존의 상태를 유지할 수 있다. (@StateObject와 달리 @ObservedObject일 경우 초기화 됨)
  @StateObject private var currentDateListViewModel = CurrentDateListViewModel()

  var body: some View {
    NavigationView {
      // currentDates의 Element들은 Identifiable 프로토콜을 준수하므로, List에서 id를 별도로 지정해줄 필요가 없다.
      List(currentDateListViewModel.currentDates, id: \.id) { currentDate in
        Text("\(currentDate.date)")
      }.listStyle(.plain)
      
        .navigationTitle("Dates")
        .navigationBarItems(trailing: Button(action: {
          // button action
          // * async closure is deprecated now. try to use Task closure block instead.
          Task {
            await currentDateListViewModel.populateAllDates()
          }
        }, label: {
          Image(systemName: "arrow.clockwise.circle")
        }))
        .task {
          // 아래 주석처리한 코드랑 동일한 동작(View의 onAppear 시기에 Task block 동작 실행)을 실행할 수 있다.
          await currentDateListViewModel.populateAllDates()
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
