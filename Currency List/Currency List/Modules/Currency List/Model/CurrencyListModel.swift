//
//  CurrencyListModel.swift
//  Currency List
//
//  Created by Dmitry Yurlagin on 14.04.2018.
//  Copyright © 2018 Dmitry Yurlagin. All rights reserved.
//

import Foundation


protocol CurrencyListModelProtocol: class {
  
  func forceRefreshList()
  var updatingInterval: TimeInterval { get set }
  var requestStatus: RequestStatus { get }
  var currencies: [Currency] { get }
  var lastUpdateDescription: String? { get }
  var didUpdate: (()->())? { get set }

}

class CurrencyListModel: CurrencyListModelProtocol {
  
  var updatingInterval: TimeInterval = 15
  
  var fetchList = ApiService().getStocks
  
  private(set) var requestStatus: RequestStatus = .none {
    didSet {
      guard oldValue != requestStatus else { return }
      DispatchQueue.main.async { [weak self] in
        self?.didUpdate?()
      }
    }
  }
  
  private(set) var lastUpdateDescription: String? = nil
  
  private(set) var currencies = [Currency]()
  
  private var fetchListDataTask: URLSessionDataTask?
  
  private var refreshTimer: Timer?

  var didUpdate: (()->())?
  
  init() {
    let notificationCenter = NotificationCenter.default
    notificationCenter.addObserver(self, selector: #selector(forceRefreshList), name: .UIApplicationWillEnterForeground, object: nil)
    notificationCenter.addObserver(self, selector: #selector(stopTasks), name: .UIApplicationDidEnterBackground, object: nil)
  }
  
  
  @objc func forceRefreshList() {
    stopTasks()
    fetchStocks()
  }
  
  
  @objc private func stopTasks() {
    flushDataTask()
    flushRefreshingTimer()
    requestStatus = .none
  }
  
  
  @objc func restartRefreshingTimer() {
    DispatchQueue.main.async { [weak self] in
      guard let weakSelf = self else { return }
      weakSelf.refreshTimer = Timer.scheduledTimer(withTimeInterval: weakSelf.updatingInterval, repeats: true, block: {  _ in
        if self?.requestStatus != .run {
          self?.forceRefreshList()
        }
      })
    }
  }
  
  
  private func flushDataTask() {
    fetchListDataTask?.cancel()
    fetchListDataTask = nil
  }
  
  
  private func flushRefreshingTimer() {
    refreshTimer?.invalidate()
    refreshTimer = nil
  }
  
  
  private func fetchStocks() {
    fetchListDataTask = try! fetchList() { [weak self] stockResult in
      do {
        let stock = try stockResult()
        self?.handle(stock)
      } catch let error as ApiServiceError {
        if error != .requestCanceled {
          self?.requestStatus = .fail
        }
      } catch {
        self?.requestStatus = .fail
      }
    }
    requestStatus = .run
  }
  
  private func handle(_ stock: StockResponse) {
    currencies = stock.stock
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "HH:mm:ss"
    lastUpdateDescription = "Last update: \(dateFormatter.string(from: Date()))"
    requestStatus = .none
    restartRefreshingTimer()
  }

}


enum RequestStatus {
  case none
  case run
  case fail
}
