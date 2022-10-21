//
//  NewsSourceListViewModel.swift
//  NewsApp
//
//  Created by Mohammad Azam on 6/30/21.
//

import Foundation

@MainActor
class NewsSourceListViewModel: ObservableObject {
  
  @Published var newsSources: [NewsSourceViewModel] = []
  
  func getSources() async {
    do {
      let newsSources = try await Webservice().fetchSources(url: Constants.Urls.sources)
      // @MainActor로 지정된 객체 내부이므로, 별도로 main thread 동작을 명시할 필요가 없음
//      DispatchQueue.main.async {
      self.newsSources = newsSources.map(NewsSourceViewModel.init)
//      }
    } catch {
      // error를 throw하지는 않음 따라서 해당 메서드 반환부에는 async만 붙으면 됨
      print(error)
    }
  }
  
}

struct NewsSourceViewModel {
  
  fileprivate var newsSource: NewsSource
  
  var id: String {
    newsSource.id
  }
  
  var name: String {
    newsSource.name
  }
  
  var description: String {
    newsSource.description
  }
  
  static var `default`: NewsSourceViewModel {
    let newsSource = NewsSource(id: "abc-news", name: "ABC News", description: "This is ABC news")
    return NewsSourceViewModel(newsSource: newsSource)
  }
}
