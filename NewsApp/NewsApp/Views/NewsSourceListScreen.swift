//
//  NewsSourceListScreen.swift
//  NewsApp
//
//  Created by Mohammad Azam on 6/30/21.
//

import SwiftUI

struct NewsSourceListScreen: View {
  
  @StateObject private var newsSourceListViewModel = NewsSourceListViewModel()
  
  var body: some View {
    
    NavigationView {
      
      List(newsSourceListViewModel.newsSources, id: \.id) { newsSource in
        NavigationLink(destination: NewsListScreen(newsSource: newsSource)) {
          NewsSourceCell(newsSource: newsSource)
        }
      }
      .listStyle(.plain)
      .task {
        await newsSourceListViewModel.getSources()
      }
//      .onAppear {
        // async function은 Task {} 블럭내에 사용하거나, View가 나타날때 사용할 목적이라면 .task viewModifier 내에서 사용할 수도 있다.
//        newsSourceListViewModel.getSources()
//      }
      .navigationTitle("News Sources")
      .navigationBarItems(trailing: Button(action: {
        // refresh the news
      }, label: {
        Image(systemName: "arrow.clockwise.circle")
      }))
    }
  }
}

struct NewsSourceListScreen_Previews: PreviewProvider {
  static var previews: some View {
    NewsSourceListScreen()
  }
}

struct NewsSourceCell: View {
  
  let newsSource: NewsSourceViewModel 
  
  var body: some View {
    VStack(alignment: .leading, spacing: 10) {
      Text(newsSource.name)
        .font(.headline)
      Text(newsSource.description)
    }
  }
}
