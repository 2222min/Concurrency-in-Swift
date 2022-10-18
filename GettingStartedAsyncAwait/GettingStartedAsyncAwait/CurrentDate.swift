//
//  CurrentDate.swift
//  GettingStartedAsyncAwait
//
//  Created by MinKyeongTae on 2022/10/19.
//

import Foundation

struct CurrentDate: Decodable, Identifiable {
  // Identifiable 프로토콜을 준수하려면 id를 정의해두어야 함
  let id = UUID()
  let date: String
  
  private enum CodingKeys: String, CodingKey {
    case date = "date"
  }
}
