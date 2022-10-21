//
//  NewsArticleListViewModel.swift
//  NewsApp
//
//  Created by Mohammad Azam on 6/30/21.
//

import Foundation

// singleton Actor, @MainActor. executer는 main dispatch queue와 동일하다. (+ iOS13)
// @MainActor를 붙히면, 해당 객체가 항상(자동적으로) Main thread에서 동작하도록 보장해준다. 따라서 내부에서 DispatchQueue.main을 명시할 필요가 없어진다.
// @MainActor가 지정되면 내부의 모든 프로퍼티, 메서드들은 main thread에서 동작한다. 내부에 추가로 main thread 명시를 할 필요가 없다.
@MainActor
class NewsArticleListViewModel: ObservableObject {
  
  @Published var newsArticles = [NewsArticleViewModel]()
  // continuation을 사용한 async func 을 getNewsBy에 가져와서 호출하고 있다. getNewsBy 또한 async func이 된다. (추가적인 error throwing은 없으므로, async throws는 아님)
  func getNewsBy(sourceId: String) async {
    do {
      let newsArticles = try await Webservice().fetchNewsAsync(sourceId: sourceId, url: Constants.Urls.topHeadlines(by: sourceId))
      // newArticles는 @Published 변수로 변경이 되면 View에 영향을 미칠 수 있는 변수다. 따라서 항상 main thread에서 동작해야 한다.
      // @MainActor로 지정된 객체 내부이기에, main 스레드를 명시할 필요없이 아래와 같이 사용해도 된다.
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
