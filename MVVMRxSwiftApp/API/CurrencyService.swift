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
    func requestSupportedPairs(completion: @escaping (Result<SupportedPairs,Error>)->Void)
    func fetchCurrencyPair(currencyPair: String) -> Observable<[String: Double]>
}

class CurrencyService: CurrencyServiceInterface {
    public func requestSupportedPairs(completion: @escaping (Result<SupportedPairs,Error>)->Void) {
        guard let urlRequest = URL(string: ServiceURL.baseURL) else {
            return
        }
        let request = URLRequest(url: urlRequest)
        let _ = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let data = data {
                do {
                    let response = try JSONDecoder().decode(SupportedPairs.self, from: data)
                    print(response)
                    completion(.success(response))
                    
                } catch {
                    print(error)
                    completion(.failure(error))
                }
            }
        
        }.resume()
    }
    
    func fetchCurrencyPair(currencyPair: String) -> Observable<[String: Double]>{
        return Observable.create { observer -> Disposable in
            guard let url = URL(string: "\(ServiceURL.baseURL)?pairs=\(currencyPair)") else {
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

