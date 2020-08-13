//
//  ExchangeTableViewCell.swift
//  MVVMRxSwiftApp
//
//  Created by Shaurya Srivastava on 10/8/2020.
//  Copyright © 2020 Shaurya Srivastava. All rights reserved.
//

import Foundation
import UIKit

class ExchangeTableViewCell: UITableViewCell {
    
    @IBOutlet weak var currencySymbolView: UIView!
    @IBOutlet weak var percentageLabel: UILabel!
    @IBOutlet weak var sellRateLabel: UILabel!
    @IBOutlet weak var buyRateLabel: UILabel!
    @IBOutlet weak var currencySumbolLabel: UILabel!
    @IBOutlet weak var trendImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

