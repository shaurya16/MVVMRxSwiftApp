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

struct CurrencyListModel {
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
        self.buyRate = Helper.addPips(value: rate)
        self.sellRate = Helper.removePips(value: rate)
    }
    
    mutating func updateSellRate(newRate: Double) {
        self.sellRate = Helper.addPips(value: newRate)
    }
    
    mutating func updateBuyRate(newRate: Double) {
        self.buyRate = Helper.removePips(value: newRate)
    }
}

struct Helper {
    static func addPips(value: Double) -> Double{
        let randomInt = Int.random(in: 1...10)
        return value + (0.0001)*Double(randomInt)
    }
    
    static func removePips(value: Double) -> Double{
        let randomInt = Int.random(in: 1...10)
        return value - (0.0001)*Double(randomInt)
    }
    
    static func calculateEquity(array: [CurrencyListModel]) -> String {
        var equityBalance = 0.0
        let _ = array.map { (item) in
            if (item.pair.hasPrefix(Constants.baseCurrency)){
                let value = Double(Constants.startingBalance) * item.baseRate
                let currentValue = (1/item.rate) * value
                equityBalance += currentValue
            }
        }
        let roundedEquityBalance = round(equityBalance*1000)/1000
        return String(roundedEquityBalance)
    }
    
    static func calculateAssests(totalCurrencyPairs: Int) -> String {
        return String(Constants.startingBalance*totalCurrencyPairs)
    }
}
