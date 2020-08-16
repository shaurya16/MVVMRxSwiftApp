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


protocol ViewModelType {
    associatedtype Input
    associatedtype Output

    var input: Input { get }
    var output: Output { get }
}

final class CurrencyListViewModel: ViewModelType {
    
    let input: Input
    let output: Output

    struct Input {
    }
    private var noOfRowToBeShown: Int = 20
    
    struct Output {
        let currencyList: PublishSubject<[CurrencyListModel]>
        let equityBalance: Driver<String>
        let assetBalance: Driver<String>
        let error: Observable<Bool>
        let reachedBottom = PublishSubject<Bool>()
    }
    
    private let bag = DisposeBag()
    
    let currencyService: CurrencyServiceInterface
    
    var dictionary = [String: CurrencyListModel]()
    
    private let currencyList = PublishSubject<[CurrencyListModel]>()
    private let equitySubject = ReplaySubject<String>.create(bufferSize: 1)
    private let assetSubject = ReplaySubject<String>.create(bufferSize: 1)
    private let errorSubject = ReplaySubject<Bool>.create(bufferSize: 1)
    private let reachedBottomSubject = ReplaySubject<Bool>.create(bufferSize: 1)
    
    init(currencyService: CurrencyServiceInterface = CurrencyService()) {
        
        self.currencyService = currencyService
        
        let error = errorSubject.asObserver()
        let equity = equitySubject.asDriver(onErrorJustReturn: "N/A")
        let asset = assetSubject.asDriver(onErrorJustReturn: "N/A")
        
        self.input = Input()
        self.output = Output(currencyList: currencyList,
                             equityBalance: equity,
                             assetBalance: asset,
                             error: error)
        
        
        fetchData()
        Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(self.updateData), userInfo: nil, repeats: true)
        fetchNextBatch()
    }
    
}

//MARK: -  Fetch Data when ViewModel is initialized, update currencyList
extension CurrencyListViewModel {
    
    private func fetchData() {
        typealias currencyPair = Result<SupportedPairs,Error>
        
        currencyService.requestSupportedPairs().subscribe(onNext: { (supportedPairs) in
            self.fetchCurrencyPairRate(pairs: supportedPairs)
        }, onError: { (error) in
            self.errorSubject.onNext(true)
        }).disposed(by: self.bag)
    }
    
    private func fetchCurrencyPairRate(pairs: [String]) {
        let allObservables = pairs.map { currencyService.fetchCurrencyPair(currencyPair: $0) }
        Observable.merge(allObservables)
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
    }
    
    @objc private func updateData() {
        if dictionary.isEmpty {
            fetchData()
        } else {
            let allObservables = dictionary.sorted { $0.key < $1.key }.map {
                        currencyService.fetchCurrencyPair(currencyPair: $0.key).share()
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
                        self.updateView()
                    }).disposed(by: self.bag)
        }
        
    }
    
    private func updateView() {
        let sortedValueArray = Array(self.dictionary.sorted { $0.key < $1.key }.map { $0.value })
        let equityBalance = Helper.calculateEquity(array: sortedValueArray)
        self.equitySubject.onNext(equityBalance)
        self.assetSubject.onNext(Helper.calculateAssests(totalCurrencyPairs: sortedValueArray.count))
        let slicedArray = Helper.sliceArray(array: sortedValueArray, startIndex: 0, endIndex: noOfRowToBeShown)
        self.currencyList.onNext(slicedArray)
    }
}

extension CurrencyListViewModel {
    func fetchNextBatch() {
        self.output.reachedBottom.onNext(false)
        self.output.reachedBottom.observeOn(MainScheduler.instance).subscribe(onNext: { value in
            if (self.noOfRowToBeShown < self.dictionary.count - 1) {
                self.noOfRowToBeShown += 20
            } else {
                self.noOfRowToBeShown = self.dictionary.count - 1
            }
            print(value)
            print(self.noOfRowToBeShown)
            if (value) {
                self.updateView()
            }
        }).disposed(by: bag)
    }
}

