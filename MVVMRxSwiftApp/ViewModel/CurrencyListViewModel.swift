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

final class CurrencyListViewModel {
    
    public var showCount = 20
    private let currencyService: CurrencyServiceInterface
    private let bag = DisposeBag()
    
    var currencyListModelArray = [CurrencyListModel]()
    var updatedCurrencyListModelArray = [CurrencyListModel]()
    
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
            let resultCurrencyListModel = self.prepareCurrencyListModel(currencyListModel: &self.currencyListModelArray)
            self.currencyList.onNext(resultCurrencyListModel)
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
            let resultCurrencyListModel = self.prepareCurrencyListModel(currencyListModel: &self.updatedCurrencyListModelArray)
            self.currencyList.onNext(resultCurrencyListModel)
            self.currencyListModelArray = self.updatedCurrencyListModelArray
        }
    }
    
    private func prepareCurrencyListModel(currencyListModel: inout [CurrencyListModel]) -> [CurrencyListModel] {
        currencyListModel.sort { (lhs: CurrencyListModel, rhs: CurrencyListModel) -> Bool in
            return lhs.pair < rhs.pair
        }
        let equityBalance = Helper.calculateEquity(array: currencyListModel)
        self.equityBalance.onNext(equityBalance)
        self.assestBalance.onNext(Helper.calculateAssests(totalCurrencyPairs: currencyListModel.count))
        let slicedArray = self.sliceArray(array: currencyListModel, startIndex: 0, endIndex: self.showCount)
        return slicedArray
    }
}

extension CurrencyListViewModel {
    func fetchNextBatch() {
        let slicedArray = self.sliceArray(array: self.currencyListModelArray, startIndex: 0, endIndex: self.showCount)
        self.currencyList.onNext(slicedArray)
    }
    
    func sliceArray(array: [CurrencyListModel], startIndex: Int, endIndex: Int) -> [CurrencyListModel] {
        if endIndex < array.count {
            return Array(array[startIndex...endIndex])
        } else {
            let length = array.count - 1
            return Array(array[startIndex...length])
        }
    }
}

