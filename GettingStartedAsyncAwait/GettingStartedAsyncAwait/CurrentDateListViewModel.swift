//
//  CurrentDateListViewModel.swift
//  GettingStartedAsyncAwait
//
//  Created by MinKyeongTae on 2022/10/19.
//

import Foundation

// GCD를 통해 main thread에서 동작시킬 수도 있지만, iOS15에서 소개된 actor를 대신 사용할 수도 있다.
// @MainActor를 사용하면 해당 객체의 동작이 Main thread에서 동작할 수 있도록 보장할 수 있다.
@MainActor
class CurrentDateListViewModel: ObservableObject {
  // ObservableObject에서 @Published 변수는 변경될때마다 UI에 변경사항이 반영된다. 따라서 ObservableObject 프로퍼티래퍼 변수의 변경은 Main thread에서 동작해야한다.
  @Published var currentDates: [CurrentDateViewModel] = []
  
  func populateAllDates() async throws {
    do {
      if let currentDate = try await Webservice().getDate() {
        let currentDateViewModel = CurrentDateViewModel(currentDate: currentDate)
        // GCD를 통해 main thread에서 동작시킬 수도 있지만, iOS15에서 소개된 actor를 대신 사용할 수도 있다.
//      DispatchQueue.main.async { [weak self] in
          self.currentDates.append(currentDateViewModel)
//      }
      }
      
    } catch {
      print(error)
    }
  }
}

struct CurrentDateViewModel {
  let currentDate: CurrentDate

  var id: UUID {
    currentDate.id
  }
  
  var date: String {
    currentDate.date
  }
}
