//
//  Parser.swift
//  Currency List
//
//  Created by Dmitry Yurlagin on 14.04.2018.
//  Copyright © 2018 Dmitry Yurlagin. All rights reserved.
//

import Foundation

extension ApiService { internal enum Parse {} }

extension ApiService.Parse {
  
  static func stock(fromData data: Data) throws -> StockResponse {
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    return try decoder.decode(StockResponse.self, from: data)
  }
}

  
struct StockResponse  {
  
  let stock: [Currency]
  let asOf: Date
  
  enum CodingKeys: String, CodingKey {
    case stock
    case asOf
  }
}


extension StockResponse: Codable {
  
  static var dateFormatter: DateFormatter {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
    return dateFormatter
  }
  
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(stock, forKey: .stock)
    let stockDateString = StockResponse.dateFormatter.string(from: asOf)
    try container.encode(stockDateString, forKey: .asOf)
  }

  
  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    stock = try values.decode([Currency].self, forKey: .stock)
    let dateString = try values.decode(String.self, forKey: .asOf)
    asOf = StockResponse.dateFormatter.date(from: dateString)!
  }
}


struct Currency: Hashable, Codable {
  let name: String
  let price: Price
  let percentChange: Double
  let volume: Int
  let symbol: String
}


struct Price: Hashable, Codable {
  let currency: String
  let amount: Double
}
