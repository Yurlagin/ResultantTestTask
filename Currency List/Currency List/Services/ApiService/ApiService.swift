//
//  ApiService.swift
//  Currency List
//
//  Created by Dmitry Yurlagin on 14.04.2018.
//  Copyright © 2018 Dmitry Yurlagin. All rights reserved.
//

import Foundation

struct ApiService {
  
  private let stocksUrl = "http://phisix-api3.appspot.com/stocks.json"
  
  var performURLRequest = ApiService.performURLRequest
  
  typealias Response = (data: Data?, response: URLResponse?, error: Error?)
  
  typealias StockCallback = (() throws -> StockResponse) -> ()
  
  
  func getStocks (callBack:  @escaping StockCallback) throws -> URLSessionDataTask {
    let stocksUrlRequest = try buildURLRequest(fromString: stocksUrl)
    func handler(response: Response) {
      callBack({
        try validate(response: response)
        guard let stockData = response.data else { throw ApiServiceError.unexpectedAnswer }
        return try Parse.stock(fromData: stockData)
      })
    }
    return performURLRequest(stocksUrlRequest, handler)
  }
  
  
  func buildURLRequest(fromString string: String) throws -> URLRequest {
    if let url = URL(string: string) {
      return URLRequest(url: url)
    } else {
      throw ApiServiceError.cantBuildUrlRequest
    }
  }
  
  
  func validate(response: Response) throws { // error handling in one place
    if let error = response.error {
      if let urlError = error as? URLError, urlError.code == URLError.cancelled {
        throw ApiServiceError.requestCanceled
      } else {
        throw ApiServiceError.connectionError
      }
    }
    
    if let httpResponse = response.response as? HTTPURLResponse {
      switch httpResponse.statusCode {
      case 200:
        break
      case 500...526:
        throw ApiServiceError.internalServerError
      // etc for other cases
      default:
        throw ApiServiceError.unexpectedAnswer
      }
    } else {
      throw ApiServiceError.unexpectedAnswer
    }
  }

}


enum ApiServiceError: Error {
  case cantBuildUrlRequest
  case unexpectedAnswer
  case connectionError
  case requestCanceled
  case internalServerError
}


extension ApiService {
  
  @discardableResult
  static private func performURLRequest(_ urlRequest: URLRequest, handler: @escaping (Response) -> ()) ->  URLSessionDataTask {
    let session = URLSession.shared
    let task = session.dataTask(with: urlRequest, completionHandler: handler)
    task.resume()
    return task
  }
  
}
