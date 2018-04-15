//
//  CurrencyListTableViewCell.swift
//  Currency List
//
//  Created by Dmitry Yurlagin on 14.04.2018.
//  Copyright © 2018 Dmitry Yurlagin. All rights reserved.
//

import UIKit

class CurrencyListTableViewCell: UITableViewCell {
  
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var volumeLabel: UILabel!
  @IBOutlet weak var amountLabel: UILabel!
  
  private var stock: Currency!
  
  func configure(withStock stock: Currency) {
    guard self.stock != stock else { return }
    self.stock = stock
    updateUI()
  }
  
  private func updateUI() {
    nameLabel.text = stock.name
    volumeLabel.text = String(stock.volume)
    amountLabel.text = String(format: "%.2f", stock.price.amount)
  }

}
