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
    NavigationView {
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
      .navigationTitle("Random Images/Quotes")
      .navigationBarItems(trailing: Button {
        // action
        Task {
          // .task viewModifier closure가 아니면, 이렇게 Task 클로져 블럭 내에 await 코드를 실행할 수도 있다.
          // -> Task { ... } 처럼 사용하는 것을 unstructured concurrency 라고 한다. (async let 같은걸 쓰는데는 structured concurrency)
          await randomImageListViewModel.getRandomImages(ids: Array(100...120))
        }
      } label: {
        // label
        Image(systemName: "arrow.clockwise.circle")
      })
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
