//
//  CurrencyService.swift
//  MVVMRxSwiftApp
//
//  Created by Shaurya Srivastava on 11/8/2020.
//  Copyright © 2020 Shaurya Srivastava. All rights reserved.
//

import Foundation
import RxSwift


protocol CurrencyServiceInterface {
    func fetchCurrencyPairs() -> Observable<SupportedPairs>
    func fetchCurrencyPair(currencyPair: String) -> Observable<CurrencyListModel>
}

class CurrencyService: CurrencyServiceInterface {
    func fetchCurrencyPairs() -> Observable<SupportedPairs>{
        return Observable.create { observer -> Disposable in
            guard let url = URL(string: "https://www.freeforexapi.com/api/live") else {
                observer.onError(NSError(domain: "", code: -1, userInfo: nil))
                return Disposables.create {}
            }
            
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                guard let data = data else {
                    observer.onError(NSError(domain: "", code: -1, userInfo: nil))
                    return
                }
                do {
                    let supportedPairs = try JSONDecoder().decode(SupportedPairs.self, from: data)
                    observer.onNext(supportedPairs)
                    observer.onCompleted()
                } catch {
                    observer.onError(error)
                }
            }
            task.resume()
            return Disposables.create {
                task.cancel()
            }
        }
    }
    
    func fetchCurrencyPair(currencyPair: String) -> Observable<CurrencyListModel>{
        return Observable.create { observer -> Disposable in
            guard let url = URL(string: "https://www.freeforexapi.com/api/live?pairs=\(currencyPair)") else {
                observer.onError(NSError(domain: "", code: -1, userInfo: nil))
                return Disposables.create {}
            }
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                guard let data = data else {
                    observer.onError(NSError(domain: "Data is nill", code: -1, userInfo: nil))
                    return
                }
                do {
                    let pairs = try JSONDecoder().decode(Pairs.self, from: data)
//                    print(pairs)
                    guard let pairRate = pairs.rates[currencyPair] else {
                        observer.onError(NSError(domain: "No rate provided", code: -1, userInfo: nil))
                        return
                    }
                    let currencyListModel = CurrencyListModel(pair: currencyPair, rate: pairRate.rate)
                    observer.onNext(currencyListModel)
                    observer.onCompleted()
                } catch {
                    observer.onError(error)
                }
            }
            task.resume()
            return Disposables.create {
                task.cancel()
            }
        }
    }
    
}

