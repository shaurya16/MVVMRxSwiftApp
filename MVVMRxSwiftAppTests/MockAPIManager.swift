//
//  MockAPIManager.swift
//  MVVMRxSwiftAppTests
//
//  Created by Shaurya Srivastava on 14/8/2020.
//  Copyright © 2020 Shaurya Srivastava. All rights reserved.
//

import Foundation
@testable import MVVMRxSwiftApp

class MockAPIManager: APIInterface {
    
    public func requestSupportedPairs(completion: @escaping (Result<SupportedPairs,Error>)->Void) {
        guard let path = Bundle.main.path(forResource: "CurrencyPairsMock", ofType: "json") else {
            print("Error: Cannot find file")
            return
        }
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
            let response = try JSONDecoder().decode(SupportedPairs.self, from: data)
            print(response)
            completion(.success(response))
            
        } catch {
            print(error)
            completion(.failure(error))
        }
    }
    
    public func requestCurrencyRate(currencyPair: String, completion: @escaping (Result<CurrencyListModel, Error>) -> Void) {
        guard let path = Bundle.main.path(forResource: "\(currencyPair)", ofType: "json") else {
            print("Error: Cannot find file")
            return
        }
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
            let response = try JSONDecoder().decode(Pairs.self, from: data)
            if let rate = response.rates[currencyPair]?.rate {
                let currencyListModel = CurrencyListModel(pair: currencyPair, rate: rate)
                completion(.success(currencyListModel))
            } else {
                completion(.failure(NSError(domain: "Cannot decode rates value", code: -1, userInfo: nil)))
            }
        } catch {
            print(error)
            completion(.failure(error))
        }

    }
    
    public func requestCurrencyRateForOnePair(currencyPair: String, completion: @escaping (Result<Double, Error>) -> Void) {
        guard let path = Bundle.main.path(forResource: "\(currencyPair)-2", ofType: "json") else {
            print("Error: Cannot find file")
            return
        }
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
            let response = try JSONDecoder().decode(Pairs.self, from: data)
            if let rate = response.rates[currencyPair]?.rate {
                completion(.success(rate))
            } else {
                completion(.failure(NSError(domain: "Cannot decode rates value", code: -1, userInfo: nil)))
            }
        } catch {
            print(error)
            completion(.failure(error))
        }
    }
}
