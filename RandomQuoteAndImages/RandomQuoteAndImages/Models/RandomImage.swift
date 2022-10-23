//
//  RandomImage.swift
//  RandomQuoteAndImages
//
//  Created by MinKyeongTae on 2022/10/23.
//

import Foundation

struct RandomImage: Decodable {
  let image: Data
  let quote: Quote
}

struct Quote: Decodable {
  let content: String
}
