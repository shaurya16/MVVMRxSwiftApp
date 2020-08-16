//
//  Utils.swift
//  MVVMRxSwiftApp
//
//  Created by Shaurya Srivastava on 17/8/2020.
//  Copyright © 2020 Shaurya Srivastava. All rights reserved.
//

import Foundation

struct Utils {
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
    
    static func addSubstring(pair: String, char: Character) -> String {
        var updatedPair = pair
        updatedPair.insert(char, at: pair.index(pair.startIndex, offsetBy: 3))
        return updatedPair
    }
    
    static func sliceArray(array: [CurrencyListModel], startIndex: Int, endIndex: Int) -> [CurrencyListModel] {
        if endIndex < array.count {
            return Array(array[startIndex...endIndex])
        } else {
            let length = array.count - 1
            return Array(array[startIndex...length])
        }
    }
}
