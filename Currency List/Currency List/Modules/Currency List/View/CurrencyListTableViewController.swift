//
//  CurrencyListTableViewController.swift
//  Currency List
//
//  Created by Dmitry Yurlagin on 14.04.2018.
//  Copyright © 2018 Dmitry Yurlagin. All rights reserved.
//

import UIKit

class CurrencyListTableViewController: UITableViewController {

  @IBAction func refreshButtonPressed(_ sender: UIBarButtonItem) {
    model.forceRefreshList()
  }
  
  struct Constants {
    static let cellId = "Currency Cell"
  }
  
  let model: CurrencyListModelProtocol = CurrencyListModel()
  
  private var stocks = [Currency]()
  
  private func updateUI() {
      switch model.requestStatus {
      case .none:
        navigationItem.leftBarButtonItem = nil
        navigationItem.prompt = model.lastUpdateDescription
          
      case .fail:
        navigationItem.leftBarButtonItem = nil
        
      case .run:
        let spinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: spinner)
        spinner.startAnimating()
      }
    
    if stocks != model.currencies {
      stocks = model.currencies
      tableView.reloadData()
    }
    
  }
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    model.didUpdate = { [weak self] in
      self?.updateUI()
    }
    model.forceRefreshList()
  }
  
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return model.currencies.count
  }
  
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellId, for: indexPath) as! CurrencyListTableViewCell
    cell.configure(withStock: model.currencies[indexPath.row])
    return cell
  }
  
  
}
