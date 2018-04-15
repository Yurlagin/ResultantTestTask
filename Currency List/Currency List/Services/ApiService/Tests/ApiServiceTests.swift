//
//  ApiServiceTests.swift
//  Currency ListTests
//
//  Created by Dmitry Yurlagin on 14.04.2018.
//  Copyright © 2018 Dmitry Yurlagin. All rights reserved.
//

import XCTest
@testable import Currency_List

class ApiServiceTests: XCTestCase {
  
  var apiService: ApiService!
  
  lazy var dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
    return dateFormatter
  }()
  
  let validHttpResponse = HTTPURLResponse(url: URL(string: "http://dontcare.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)
  
  
  override func setUp() {
    super.setUp()
    apiService = ApiService()
  }
  
  
  func testGetStocksPositiveFlow() {
    
    let validStocksResponse = StockResponse(stock: [Currency(name: "2GO Group",
                                                            price: Price(currency: "PHP",
                                                                         amount: 17.56),
                                                            percentChange: -1.9,
                                                            volume: 98600,
                                                            symbol: "2GO")],
                                             asOf: dateFormatter.date(from: "2018-04-13T15:20:00+08:00")!)
    
    let validStocksData = try! JSONEncoder().encode(validStocksResponse)
    let validResponse = ApiService.Response(validStocksData, validHttpResponse, nil)
    
    apiService.performURLRequest = { request, callback in
      callback(validResponse)
      return URLSessionDataTask()
    }
    
    let requestExpectation = expectation(description: "stocks request check")
    
    XCTAssertNoThrow(
      try apiService.getStocks { stockResult in
        requestExpectation.fulfill()
        if let stock = try? stockResult() {
          XCTAssert(stock.stock == validStocksResponse.stock)
          XCTAssert(stock.asOf == validStocksResponse.asOf)
        } else {
          XCTFail()
        }
      }
    )
    
    waitForExpectations(timeout: 0, handler: nil)
    
  }
  
  
  func testThatValidationThrowsConnectionErrorWhenUrlErrorArrives() {
    let responseWithUrlError = ApiService.Response(nil, nil, NSError(domain: "some.domain", code: -1009, userInfo: nil))
    XCTAssertThrowsError(try apiService.validate(response: responseWithUrlError), "") { (error) in
      if let error = error as? ApiServiceError {
        XCTAssertEqual(error, ApiServiceError.connectionError)
      } else {
        XCTFail("Incorrect validation error")
      }
    }
  }
  
  
  func testThatValidationThrowsErrorWhenHttpErrorArrives() {
    let httpResponseWithError = HTTPURLResponse(url: URL(string: "http://dontcare.com")!, statusCode: 400, httpVersion: nil, headerFields: nil)
    let response = ApiService.Response(nil, httpResponseWithError, nil)
    XCTAssertThrowsError(try apiService.validate(response: response), "") { (error) in
      if let error = error as? ApiServiceError {
        XCTAssertEqual(error, .unexpectedAnswer)
      } else {
        XCTFail("Incorrect validation error")
      }
    }
  }
  
  
  func testParsingError() {
    let validStocksResponse = StockResponse(stock: [Currency(name: "2GO Group",
                                                            price: Price(currency: "PHP",
                                                                         amount: 17.56),
                                                            percentChange: -1.9,
                                                            volume: 98600,
                                                            symbol: "2GO")],
                                             asOf: dateFormatter.date(from: "2018-04-13T15:20:00+08:00")!)
    
    let encoder = JSONEncoder()
    encoder.keyEncodingStrategy = .convertToSnakeCase
    let validStocksData = try! encoder.encode(validStocksResponse)
    var incorrectStocksObject = try! JSONSerialization.jsonObject(with: validStocksData, options: []) as! [String: Any]
    incorrectStocksObject["as_of"] = nil
    let incorrectData = try! JSONSerialization.data(withJSONObject: incorrectStocksObject, options: .prettyPrinted)
    XCTAssertThrowsError(try ApiService.Parse.stock(fromData: incorrectData), "") { (error) in
      XCTAssert(error is DecodingError)
    }
  }
  
  
  
}
