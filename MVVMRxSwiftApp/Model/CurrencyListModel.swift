//
//  CurrencyListModel.swift
//  MVVMRxSwiftApp
//
//  Created by Shaurya Srivastava on 11/8/2020.
//  Copyright © 2020 Shaurya Srivastava. All rights reserved.
//

import Foundation

enum trend {
    case positive
    case negative
    case none
}

struct Constants {
    static var baseCurrency = "USD"
    static var startingBalance = 10000
}

struct CurrencyListModel: Equatable {
    var pair: String
    var rate: Double = 0.0 {
        didSet {
            percentage = ((rate - baseRate)/baseRate)*100
            let roundedPercentage = Double(round(1000*percentage)/1000)
            percentage = roundedPercentage
            if (percentage == 0.000) {
                percentage = abs(percentage)
                trend = .none
            } else if (percentage > 0){
                trend = .positive
            } else{
                trend = .negative
            }
            updateSellRate(newRate: rate)
            updateBuyRate(newRate: rate)
        }
    }
    let baseRate: Double
    var sellRate: Double = 0.0
    var buyRate: Double
    var percentage: Double = 0.0
    var trend: trend = .none
    
    init(pair: String, rate: Double) {
        self.pair = pair
        self.rate = rate
        self.baseRate = rate
        self.buyRate = Utils.addPips(value: rate)
        self.sellRate = Utils.removePips(value: rate)
    }
    
    mutating func updateSellRate(newRate: Double) {
        self.sellRate = Utils.addPips(value: newRate)
    }
    
    mutating func updateBuyRate(newRate: Double) {
        self.buyRate = Utils.removePips(value: newRate)
    }
}

