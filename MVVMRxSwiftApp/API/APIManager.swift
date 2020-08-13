//
//  APIManager.swift
//  MVVMRxSwiftApp
//
//  Created by Shaurya Srivastava on 12/8/2020.
//  Copyright © 2020 Shaurya Srivastava. All rights reserved.
//

import Foundation
import UIKit
import RxSwift


protocol APIInterface {
        func requestSupportedPairs(completion: @escaping (Result<SupportedPairs,Error>)->Void)
        func requestCurrencyRate(currencyPair: String, completion: @escaping (Result<CurrencyListModel, Error>) -> Void)
        func requestCurrencyRateForOnePair(currencyPair: String, completion: @escaping (Result<Double, Error>) -> Void)
}

class APIManager: APIInterface {
    
    public func genericRequest<T: Decodable>(url: String, completion: @escaping (Result<T, Error>) -> Void) {
        guard let urlRequest = URL(string: url) else {
            return
        }
        let request = URLRequest(url: urlRequest)
        let _ = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let data = data {
                do {
                    let response = try JSONDecoder().decode(T.self, from: data)
                    completion(.success(response))
                } catch {
                    completion(.failure(error))
                }
            }
        
        }.resume()
    }
    
    public func requestSupportedPairs(completion: @escaping (Result<SupportedPairs,Error>)->Void) {
        guard let urlRequest = URL(string: "https://www.freeforexapi.com/api/live") else {
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
    
    
    public func requestCurrencyRate(currencyPair: String, completion: @escaping (Result<CurrencyListModel, Error>) -> Void) {
        guard let urlRequest = URL(string: "https://www.freeforexapi.com/api/live?pairs=\(currencyPair)") else {
            return
        }
        let request = URLRequest(url: urlRequest)
        let _ = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let data = data {
                do {
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
        
        }.resume()
    }
    
    public func requestCurrencyRateForOnePair(currencyPair: String, completion: @escaping (Result<Double, Error>) -> Void) {
        guard let urlRequest = URL(string: "https://www.freeforexapi.com/api/live?pairs=\(currencyPair)") else {
            return
        }
        let request = URLRequest(url: urlRequest)
        let _ = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let data = data {
                do {
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
        
        }.resume()
    }
}
