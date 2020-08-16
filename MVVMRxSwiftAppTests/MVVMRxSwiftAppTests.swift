//
//  MVVMRxSwiftAppTests.swift
//  MVVMRxSwiftAppTests
//
//  Created by Shaurya Srivastava on 10/8/2020.
//  Copyright © 2020 Shaurya Srivastava. All rights reserved.
//

import XCTest
import RxSwift
import RxTest

@testable import MVVMRxSwiftApp

class MVVMRxSwiftAppTests: XCTestCase {
    
    var scheduler: TestScheduler!
    var disposeBag: DisposeBag!
    var service: CurrencyServiceInterface!
    var mockViewModel: CurrencyListViewModel!
    
    var resultArray = [CurrencyListModel]()
    
    override func setUp() {
        super.setUp()
        self.service = MockCurrencyService()
        self.mockViewModel = CurrencyListViewModel(currencyService: service)
        self.scheduler = TestScheduler(initialClock: 0)
        self.disposeBag = DisposeBag()
    }

    func test_ViewModel_FetchData() {
        
        let pair = scheduler.createObserver([CurrencyListModel].self)
        
        let expectedPair: [CurrencyListModel] =
            [
                CurrencyListModel(pair: "USDCAD", rate: 1.323075),
                CurrencyListModel(pair: "USDCHF", rate: 0.91086),
                CurrencyListModel(pair: "USDEUR", rate: 0.84735),
                CurrencyListModel(pair: "USDGBP", rate: 0.76595),
                CurrencyListModel(pair: "USDHKD", rate: 7.75065),
                CurrencyListModel(pair: "USDINR", rate: 74.88655),
                CurrencyListModel(pair: "USDCAD", rate: 107.007506),
            ]
        
        self.mockViewModel
            .output
            .currencyList
            .bind(to: pair)
            .disposed(by: disposeBag)
        
        let results = scheduler.record(mockViewModel.output.currencyList, disposeBag: disposeBag)
        
        scheduler
            .createColdObservable([.next(10, ())])
            .bind(to: self.mockViewModel.input.validate)
            .disposed(by: disposeBag)
        scheduler.start()
        
        _ = results.events.map { event in
            
            XCTAssertEqual(event.value.element?[0].pair, expectedPair[0].pair)
            XCTAssertEqual(event.value.element?[0].baseRate, expectedPair[0].baseRate)
            XCTAssertEqual(event.value.element?[0].rate, expectedPair[0].rate)
        }
    }
    
    func test_ViewModel_UpdateData() {
        let pair = scheduler.createObserver([CurrencyListModel].self)
        
        let _ : [CurrencyListModel] =
            [
                CurrencyListModel(pair: "USDCAD", rate: 1.323075),
                CurrencyListModel(pair: "USDCHF", rate: 0.91086),
                CurrencyListModel(pair: "USDEUR", rate: 0.84735),
                CurrencyListModel(pair: "USDGBP", rate: 0.76595),
                CurrencyListModel(pair: "USDHKD", rate: 7.75065),
                CurrencyListModel(pair: "USDINR", rate: 74.88655),
                CurrencyListModel(pair: "USDCAD", rate: 107.007506),
            ]

        self.mockViewModel
            .output
            .currencyList
            .bind(to: pair)
            .disposed(by: disposeBag)
        
        let results = scheduler.record(mockViewModel.output.currencyList, disposeBag: disposeBag)
        scheduler
            .createColdObservable([.next(10, ())])
            .delay(.seconds(80), scheduler: scheduler)
            .bind(to: self.mockViewModel.input.validate)
            .disposed(by: disposeBag)
        
        scheduler.start()
        
        print("Total Events: \(results.events[0])\n")
    }
    
}

extension TestScheduler {
/**
    Creates a `TestableObserver` instance which immediately subscribes to the `source`
    */
   func record<O: ObservableConvertibleType>(
       _ source: O,
       disposeBag: DisposeBag
   ) -> TestableObserver<O.Element> {
       let observer = self.createObserver(O.Element.self)
       source
           .asObservable()
           .bind(to: observer)
           .disposed(by: disposeBag)
       return observer
   }
}
