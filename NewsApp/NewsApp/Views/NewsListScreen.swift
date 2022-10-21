//
//  NewsListScreen.swift
//  NewsApp
//
//  Created by Mohammad Azam on 6/30/21.
//

import SwiftUI

struct NewsListScreen: View {
  
  let newsSource: NewsSourceViewModel
  @StateObject private var newsArticleListViewModel = NewsArticleListViewModel()
  
  var body: some View {
    
    NavigationView {
      
      List(newsArticleListViewModel.newsArticles, id: \.id) { newsArticle in
        NewsArticleCell(newsArticle: newsArticle)
      }
      .listStyle(.plain)
      .task {
        // .task viewModifier 블럭내에서 async func을 사용 가능하다. 해당 블럭을 view의 onAppear 시점에 동작한다.
        await newsArticleListViewModel.getNewsBy(sourceId: newsSource.id)
      }
      .navigationTitle(newsSource.name)
    }
  }
}

struct NewsListScreen_Previews: PreviewProvider {
  static var previews: some View {
    NewsListScreen(newsSource: NewsSourceViewModel.default)
  }
}

struct NewsArticleCell: View {
  
  let newsArticle: NewsArticleViewModel
  
  var body: some View {
    HStack(alignment: .top) {
      AsyncImage(url: newsArticle.urlToImage) { image in
        image.resizable()
          .frame(maxWidth: 100, maxHeight: 100)
      } placeholder: {
        ProgressView("Loading...")
          .frame(maxWidth: 100, maxHeight: 100)
      }
      
      VStack {
        Text(newsArticle.title)
          .fontWeight(.bold)
        Text(newsArticle.description)
      }
    }
  }
}