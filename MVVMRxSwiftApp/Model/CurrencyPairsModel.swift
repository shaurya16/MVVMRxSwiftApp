//
//  CurrencyPairModel.swift
//  MVVMRxSwiftApp
//
//  Created by Shaurya Srivastava on 11/8/2020.
//  Copyright © 2020 Shaurya Srivastava. All rights reserved.
//

import Foundation

struct SupportedPairs: Decodable {
    let supportedPairs: [String]
}

struct Pairs: Decodable {
    let rates: [String: PairRate]
    let code: Int
}

struct PairRate: Decodable {
    let rate: Double
    let timestamp: Int
}
