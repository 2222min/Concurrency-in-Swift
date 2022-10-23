//
//  Constants.swift
//  RandomQuoteAndImages
//
//  Created by MinKyeongTae on 2022/10/23.
//

import Foundation

struct Constants {
  
  struct Urls {
    static func getRandomImageUrl() -> URL? {
      return URL(string: "https://picsum.photos/200/300?uuid=\(UUID().uuidString)")
    }
    
    static let randomQuoteUrl: URL? = URL(string: "https://api.quotable.io/random")
  }
}
