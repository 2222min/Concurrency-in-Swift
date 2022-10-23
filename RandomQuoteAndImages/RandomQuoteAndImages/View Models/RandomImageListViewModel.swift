//
//  RandomImageListViewModel.swift
//  RandomQuoteAndImages
//
//  Created by MinKyeongTae on 2022/10/23.
//

import UIKit

@MainActor
class RandomImageListViewModel: ObservableObject {
  
  @Published var randomImages: [RandomImageViewModel] = []
  
  func getRandomImages(ids: [Int]) async {
    // throws 메서드가 아니므로, do { } catch 표현을 적용해준다.
    do {
      let randomImages = try await Webservice().getRandomImages(ids: ids)
      // @Publiished properties should be set on the main thread!!
      // RandomImageListViewModel이 @MainActor로 지정되어있으므로, DispatchQueue.main이나 MainActor.run으로 메인스레드 정의를 별도로 할 필요가 없어요.
      self.randomImages = randomImages.map(RandomImageViewModel.init)
    } catch {
      print(error)
    }
  }
}

struct RandomImageViewModel: Identifiable {
  let id = UUID()
  fileprivate let randomImage: RandomImage
  
  var image: UIImage? {
    UIImage(data: randomImage.image)
  }
  
  var quote: String {
    randomImage.quote.content
  }
}
