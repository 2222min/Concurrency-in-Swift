//
//  ContentView.swift
//  RandomQuoteAndImages
//
//  Created by MinKyeongTae on 2022/10/23.
//

import SwiftUI

struct ContentView: View {
  
  @StateObject private var randomImageListViewModel = RandomImageListViewModel()

  var body: some View {
    List(randomImageListViewModel.randomImages) { randomImage in
      HStack {
        randomImage.image.map {
          Image(uiImage: $0)
            .resizable()
            .aspectRatio(contentMode: .fit)
        }
        Text(randomImage.quote)
      }
    }.task {
      // onAppear일때 async 동작을 취할 수 있다. (await 사용 가능)
      await randomImageListViewModel.getRandomImages(ids: Array(100...120))
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
