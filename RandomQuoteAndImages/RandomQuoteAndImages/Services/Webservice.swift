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
  
  func getRandomImages(ids: [Int]) async throws -> [RandomImage] {
    for id in ids {
      let randomImage = try await getRandomImage(id: id)
      randomImages.append(randomImage)
    }
    
    return randomImages
  }
  
  private func getRandomImage(id: Int) async throws -> RandomImage {
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
