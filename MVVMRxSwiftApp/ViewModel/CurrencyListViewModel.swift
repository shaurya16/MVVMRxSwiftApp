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
    
    var dictionary = [String: CurrencyListModel]()
    
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
        
        currencyService.requestSupportedPairs { (response: currencyPair) in
            switch response {
            case .success(let supportedPairArray):
                self.fetchCurrencyPairRate(pairs: supportedPairArray.supportedPairs)
                    .subscribe(onNext: { (pairDataDict) in
                        for (key, value) in pairDataDict {
                            print(pairDataDict)
                            let item = CurrencyListModel(pair: key, rate: value)
                            self.dictionary[key] = item
                        }
                    }, onCompleted: {
                        print("Completed")
                        self.updateView()
                    }).disposed(by: self.bag)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func fetchCurrencyPairRate(pairs: [String]) -> Observable<[String: Double]> {
        let allObservables = pairs.map { currencyService.fetchCurrencyPair(currencyPair: $0) }
        return Observable.merge(allObservables)
    }
    
    public func updateData() {
        let allObservables = dictionary.sorted { $0.key < $1.key }.map {
            currencyService.fetchCurrencyPair(currencyPair: $0.key)
        }
        Observable.merge(allObservables)
            .subscribe(onNext: { (pairDataDict) in
                for (key, value) in pairDataDict {
                    guard var item = self.dictionary[key] else { return }
                    print(pairDataDict)
                    print("NewRate: \(value)")
                    print("BaseRate: \(item.baseRate)")
                    print("Old%: \(item.percentage)")
                    guard let newRate = pairDataDict[key] else { return }
                    item.rate = newRate
                    self.dictionary.updateValue(item, forKey: key)
                    print("New%: \(item.percentage)")
                }
            }, onCompleted: {
                print("Update Completed")
//                let equityBalance = Helper.calculateEquity(array: currencyListModel)
//                self.equityBalance.onNext(equityBalance)
//                self.assestBalance.onNext(Helper.calculateAssests(totalCurrencyPairs: currencyListModel.count))
//                let slicedArray = self.sliceArray(array: currencyListModel, startIndex: 0, endIndex: self.showCount)
//                return slicedArray
                self.updateView()
            }).disposed(by: self.bag)
    }
    
    func updateView() {
        let sortedValueArray = Array(self.dictionary.sorted { $0.key < $1.key }.map { $0.value })
        self.currencyList.onNext(sortedValueArray)
    }
}

extension CurrencyListViewModel {
    func fetchNextBatch() {
//        let slicedArray = self.sliceArray(array: self.currencyListModelArray, startIndex: 0, endIndex: self.showCount)
//        self.currencyList.onNext(slicedArray)
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

