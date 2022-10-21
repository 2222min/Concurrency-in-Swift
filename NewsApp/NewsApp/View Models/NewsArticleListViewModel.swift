//
//  NewsArticleListViewModel.swift
//  NewsApp
//
//  Created by Mohammad Azam on 6/30/21.
//

import Foundation

// @MainActor를 붙히면, 해당 객체가 항상 Main thread에서 동작하도록 보장해준다. 따라서 내부에서 DispatchQueue.main을 명시할 필요가 없어진다.
@MainActor
class NewsArticleListViewModel: ObservableObject {
  
  @Published var newsArticles = [NewsArticleViewModel]()
  // continuation을 사용한 async func 을 getNewsBy에 가져와서 호출하고 있다. getNewsBy 또한 async func이 된다. (추가적인 error throwing은 없으므로, async throws는 아님)
  func getNewsBy(sourceId: String) async {
    do {
      let newsArticles = try await Webservice().fetchNewsAsync(sourceId: sourceId, url: Constants.Urls.topHeadlines(by: sourceId))
      self.newsArticles = newsArticles.map(NewsArticleViewModel.init)
    } catch {
      print(error)
    }
  }
}

struct NewsArticleViewModel {
  
  let id = UUID()
  fileprivate let newsArticle: NewsArticle
  
  var title: String {
    newsArticle.title
  }
  
  var description: String {
    newsArticle.description ?? ""
  }
  
  var author: String {
    newsArticle.author ?? ""
  }
  
  var urlToImage: URL? {
    URL(string: newsArticle.urlToImage ?? "")
  }
  
}
