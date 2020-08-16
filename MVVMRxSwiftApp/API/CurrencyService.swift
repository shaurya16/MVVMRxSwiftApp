//
//  CurrencyService.swift
//  MVVMRxSwiftApp
//
//  Created by Shaurya Srivastava on 11/8/2020.
//  Copyright © 2020 Shaurya Srivastava. All rights reserved.
//

import Foundation
import RxSwift

struct ServiceURL {
    static let baseURL = "https://www.freeforexapi.com/api/live"
}

protocol CurrencyServiceInterface {
    func requestSupportedPairs() -> Observable<[String]>
    func fetchCurrencyPair(currencyPair: String) -> Observable<[String: Double]>
}

class CurrencyService: CurrencyServiceInterface {
    public func requestSupportedPairs() -> Observable<[String]> {
        return Observable.create { observer -> Disposable in
            guard let url = URL(string: ServiceURL.baseURL) else {
                observer.onError(NSError(domain: "Error creating URL, Please check the URL again!", code: -1, userInfo: nil))
                return Disposables.create {}
            }
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                
                switch response {
                case .none:
                    guard let error = error else { return }
                    observer.onError(error)
                case .some(_):
                    guard let data = data else {
                        observer.onError(NSError(domain: "Data is nill", code: -1, userInfo: nil))
                        return
                    }
                    do {
                        let pairs = try JSONDecoder().decode(SupportedPairs.self, from: data)
                        let supportedPairs = pairs.supportedPairs
                        
                        observer.onNext(supportedPairs)
                        observer.onCompleted()
                    } catch {
                        observer.onError(error)
                    }
                }
            }
            task.resume()
            return Disposables.create {
                task.cancel()
            }
        }
    }
    
    func fetchCurrencyPair(currencyPair: String) -> Observable<[String: Double]>{
        return Observable.create { observer -> Disposable in
            guard let url = URL(string: "\(ServiceURL.baseURL)?pairs=\(currencyPair)") else {
                observer.onError(NSError(domain: "Error creating URL, Please check the URL again!", code: -1, userInfo: nil))
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
                        print("Cannot find rates for the pair \(currencyPair)")
                        return
                    }
                    let pairData = [currencyPair: pairRate.rate]
                    observer.onNext(pairData)
                    observer.onCompleted()
                } catch {
                    print("JSON Decoder error, cannot find rates for the pair \(currencyPair)")
                    observer.onCompleted()
                }
            }
            task.resume()
            return Disposables.create {
                task.cancel()
            }
        }
    }
}

