//
//  MockAPIManager.swift
//  MVVMRxSwiftAppTests
//
//  Created by Shaurya Srivastava on 14/8/2020.
//  Copyright © 2020 Shaurya Srivastava. All rights reserved.
//

import Foundation
import RxSwift
@testable import MVVMRxSwiftApp

class MockCurrencyService: CurrencyServiceInterface {
    func requestSupportedPairs() -> Observable<[String]> {
        return Observable.create { observer -> Disposable in
            guard let path = Bundle.main.path(forResource: "CurrencyPairsMock", ofType: "json") else {
                print("Error: Cannot find file")
                return Disposables.create {}
            }
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let pairs = try JSONDecoder().decode(SupportedPairs.self, from: data)
                let supportedPairs = pairs.supportedPairs
                
                observer.onNext(supportedPairs)
                observer.onCompleted()
            } catch {
                observer.onError(error)
            }
            return Disposables.create {}
        }
    }
    
    func fetchCurrencyPair(currencyPair: String) -> Observable<[String : Double]> {
        return Observable.create { observer -> Disposable in
            var file: String = ""
            if Bool.random() {
                file = "\(currencyPair)"
            } else {
                file = "\(currencyPair)-2"
            }
            guard let path = Bundle.main.path(forResource: "\(file)", ofType: "json") else {
                print("Error: Cannot find file")
                return Disposables.create {}
            }
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let pairs = try JSONDecoder().decode(Pairs.self, from: data)
                guard let pairRate = pairs.rates[currencyPair] else {
                    print("Cannot find rates for the pair \(currencyPair)")
                    return Disposables.create {}
                }
                let pairData = [currencyPair: pairRate.rate]
                observer.onNext(pairData)
                observer.onCompleted()
            } catch {
                print(error)
            }
            return Disposables.create {}
        }
    }
}
