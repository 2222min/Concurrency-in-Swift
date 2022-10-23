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
    
    let webservice = Webservice()
    // 새로고침 할때 previous images를 보지 않고 싶다면, 아래와 같이 randomImages를 초기화 하고 API 요청하면 됨.
    randomImages = []
    // throws 메서드가 아니므로, do { } catch 표현을 적용해준다.
    do {
      try await withThrowingTaskGroup(of: (Int, RandomImage).self, body: { group in
        
        for id in ids {
          group.addTask {
            return (id, try await webservice.getRandomImage(id: id))
          }
        }
        
        // API 요청은 모두 concurrently 하게 동작하고, @Published 프로퍼티의 갱신은 순차적으로 업데이트하게 되면서 앱 실행 시에 보다 빠르게 UI가 업데이트 되는 것을 볼 수 있다.
        // 첫번째 API요청이 끝나고나서야 두번째 API요청이 끝나는 방식이 아닌, 모든 API요청을 concurrently하게 하기 때문!
        // * task group을 사용하지 않았다면? 각 API 요청은 동시에 동작하지 않으므로 더 오래 걸림
        for try await (_, randomImage) in group {
          randomImages.append(RandomImageViewModel(randomImage: randomImage))
        }
        
      })
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
