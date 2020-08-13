//
//  CurrencyListViewModel.swift
//  MVVMRxSwiftApp
//
//  Created by Shaurya Srivastava on 11/8/2020.
//  Copyright © 2020 Shaurya Srivastava. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

struct Constants {
    static var baseCurrency = "USD"
    static var startingBalance = 10000
}

final class CurrencyListViewModel {
    
    private let currencyService: CurrencyServiceInterface
    private let bag = DisposeBag()
    
    var currencyListModelArray = [CurrencyListModel]()
    var updatedCurrencyListModelArray = [CurrencyListModel]()
    var assests = 0.0
    
    var baseCurrencyListModelArray = [CurrencyListModel]()
    var updatedBaseCurrencyListModelArray = [CurrencyListModel]()
    
    public let currencyList : PublishSubject<[CurrencyListModel]> = PublishSubject()
    public let equityBalance: PublishSubject<String?> = PublishSubject()
    public let assestBalance: PublishSubject<String?> = PublishSubject()
    
    init(currencyService: CurrencyServiceInterface = CurrencyService()) {
        self.currencyService = currencyService
    }
    
}

//MARK: -  Fetch Data when the App starts, update ViewModel with currencyListModelArray
extension CurrencyListViewModel {
    
    public func fetchData() {
        typealias currencyPair = Result<SupportedPairs,Error>
        
        APIManager.requestSupportedPairs { (response: currencyPair) in
            switch response {
            case .success(let supportedPairArray):
                self.fetchCurrencyPairRate(pairs: supportedPairArray.supportedPairs)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func fetchCurrencyPairRate(pairs: [String]) {
        typealias result = Result<CurrencyListModel,Error>
        let myGroup = DispatchGroup()
        for item in pairs {
            myGroup.enter()
            APIManager.requestCurrencyRate(currencyPair: item) { (response: result) in
                switch response {
                case .success(let currencyListModel):
                    print("Response: \(currencyListModel)")
                    self.currencyListModelArray.append(currencyListModel)
                case .failure(let error):
                    print("Error: \(error)")
                }
                myGroup.leave()
            }
        }
        
        myGroup.notify(queue: .main) {
            print("Completed")
            print(self.currencyListModelArray.count)
            self.currencyListModelArray.sort { (lhs: CurrencyListModel, rhs: CurrencyListModel) -> Bool in
                return lhs.pair < rhs.pair
            }
            let equityBalance = self.calculateEquity(array: self.currencyListModelArray)
            self.equityBalance.onNext(equityBalance)
            self.assestBalance.onNext(self.calculateAssests())
            self.currencyList.onNext(self.currencyListModelArray)
        }
    }
}
 
//MARK: -  Update Data at an interval, update ViewModel with updatedCurrencyListModelArray
extension CurrencyListViewModel {
    func update() {
        typealias result = Result<Double,Error>
        let myGroup2 = DispatchGroup()
        self.updatedCurrencyListModelArray.removeAll()
        for var item in currencyListModelArray {
            myGroup2.enter()
            APIManager.requestCurrencyRateForOnePair(currencyPair: item.pair) { (response: result) in
                switch response {
                case .success(let newRate):
                    print(item.pair)
                    print("NewRate: \(newRate)")
                    print("BaseRate: \(item.baseRate)")
                    print("Old%: \(item.percentage)")
                    item.rate = newRate
                    print("New%: \(item.percentage)")
                    self.updatedCurrencyListModelArray.append(item)
                case .failure(let error):
                    print(error)
                }
                myGroup2.leave()
            }
        }
        
        myGroup2.notify(queue: .main) {
            print("Completed Update")
            print(self.updatedCurrencyListModelArray.count)
            self.updatedCurrencyListModelArray.sort { (lhs: CurrencyListModel, rhs: CurrencyListModel) -> Bool in
                return lhs.pair < rhs.pair
            }
            let equityBalance = self.calculateEquity(array: self.updatedCurrencyListModelArray)
            self.equityBalance.onNext(equityBalance)
            self.assestBalance.onNext(self.calculateAssests())
            self.currencyList.onNext(self.updatedCurrencyListModelArray)
        }
    }
}

extension CurrencyListViewModel {
    func calculateEquity(array: [CurrencyListModel]) -> String {
        var equityBalance = 0.0
        let _ = array.map { (item) in
            if (item.pair.hasPrefix("USD")){
                let value = Double(Constants.startingBalance) * item.baseRate
                let currentValue = (1/item.rate) * value
                equityBalance += currentValue
            }
        }
        print("Total Assets: \(assests)")
        print("Equity Balance: \(equityBalance)")
        let roundedEquityBalance = round(equityBalance*1000)/1000
        return String(roundedEquityBalance)
    }
    
    func calculateAssests() -> String {
        return String(Constants.startingBalance*self.currencyListModelArray.count)
    }
}
