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
  
  private var currency: Currency!
  
  func configure(withCurrency currency: Currency) {
    guard self.currency != currency else { return }
    self.currency = currency
    updateUI()
  }
  
  private func updateUI() {
    nameLabel.text = currency.name
    volumeLabel.text = String(currency.volume)
    amountLabel.text = String(format: "%.2f", currency.price.amount)
  }

}
