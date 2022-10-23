//
//  Webservice.swift
//  RandomQuoteAndImages
//
//  Created by MinKyeongTae on 2022/10/23.
//

import Foundation

enum NetworkError: Error {
  case badUrl
  case invalidImageId(Int)
  case decodingError
}

class Webservice {
  
  var randomImages: [RandomImage] = []
  
  // task group을 사용해서 loop 내의 각 image 요청을 모두 concurrent하게 수행하도록 해보자.
  func getRandomImages(ids: [Int]) async throws -> [RandomImage] {
    try await withThrowingTaskGroup(of: (Int, RandomImage).self, body: { group in
      for id in ids {
        // 루프내 각 task 각각 concurret task group을 만든다.
        // task group 내의 addTask 클로져 내부에 concurrently 동작시킬 작업을 작업하고, of: 레이블에 설정한 타입에 맞게 결과를 반환한다.
        group.addTask {
          let randomImage = try await self.getRandomImage(id: id)
          return (id, randomImage)
        }
      }
      
      // group에 추가했던 task들을 순차적으로 suspending하여 결과값을 randomImages에 appending한다.
      // => 모든 getRandomImage 요청들은 concurrently 동작을 한다. 이후 아래 for try await loop에서 suspending을 하며, 수신한 값을 순차적으로 randomImages에 추가한다.
      // => task group을 사용하지 않았을때 : loop의 각 task 내부 동작은 async하지만, 각 getRandomImage 결과값을 얻기 전까지 suspending되어 루프 다음 task(getRandomImage)를 동시에 수행하지 못했음.
      // => task group을 사용했을때 : loop의 각 task는 concurrently, asynchronous 하게 동작한다. suspending은 for try await loop에서 발생한다.
      for try await (_, randomImage) in group {
        self.randomImages.append(randomImage)
      }
    })
    
    return randomImages
  }
  
  func getRandomImage(id: Int) async throws -> RandomImage {
    guard let url = Constants.Urls.getRandomImageUrl() else {
      throw NetworkError.badUrl
    }
    
    guard let randomQuoteUrl = Constants.Urls.randomQuoteUrl else {
      throw NetworkError.badUrl
    }
    
    // * 함상 await이 명시되어있는 곳은 비동기 처리 중 subpending 되는 곳임(unstructured(Task { ... }) / structured(async let) concurrency)
    // 아래 두개 API 요청 작업은 concurretly하게 실행하기 위해 async let (structured concurrency)를 사용한다.
    // 아래 2개 라인은 즉시 return 받고 다음 라인으로 간다. 그 후 await을 사용하는 곳에서 suspending이 된다.
    async let (imageData, _) = URLSession.shared.data(from: url)
    async let (randomQuoteData, _) = URLSession.shared.data(from: randomQuoteUrl)
    // 아래에서 첫번째 suspending
    guard let quote = try? JSONDecoder().decode(Quote.self, from: try await randomQuoteData) else {
      throw NetworkError.decodingError
    }
    
    // 아래에서 두번째 suspending
    return RandomImage(image: try await imageData, quote: quote)
  }
  
  // * Tip : throws가 붙으면, try 작업을 할때 do 블럭을 반드시 명시할 필요가 없다.
  /*
  private func throwman() throws {
    /*
    do {
      let quote = try JSONDecoder().decode(Quote.self, from: Data())
    } catch {
      throw error
    }
     */
    let quote = try JSONDecoder().decode(Quote.self, from: Data())
  }
   */
}
