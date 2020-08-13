//
//  MVVMRxSwiftAppTests.swift
//  MVVMRxSwiftAppTests
//
//  Created by Shaurya Srivastava on 10/8/2020.
//  Copyright © 2020 Shaurya Srivastava. All rights reserved.
//

import XCTest

@testable import MVVMRxSwiftApp

class MVVMRxSwiftAppTests: XCTestCase {
    
    var viewModel: CurrencyListViewModel!
    
    override func setUp() {
        let mockAPIManager = MockAPIManager()
        let viewModel = CurrencyListViewModel(apiManager: mockAPIManager)
        self.viewModel = viewModel
    }

    func test_ViewModel_FetchData() throws {
        viewModel.fetchData()
        XCTAssertEqual(viewModel.currencyListModelArray.first?.pair, "USDEUR")
        XCTAssertEqual(viewModel.currencyListModelArray.first?.rate, 0.84735)
        XCTAssertEqual(viewModel.currencyListModelArray.first?.baseRate, viewModel.currencyListModelArray.first?.rate)
        XCTAssertEqual(viewModel.currencyListModelArray.first?.percentage, 0.0)
        XCTAssertNotNil(viewModel.currencyListModelArray.first?.buyRate)
        XCTAssertNotNil(viewModel.currencyListModelArray.first?.sellRate)
        
        XCTAssertEqual(viewModel.currencyListModelArray.count, 7)
    }
    
    
    func test_ViewModel_UpdateData() throws {
        viewModel.fetchData()
        viewModel.update()
        XCTAssertEqual(viewModel.updatedCurrencyListModelArray.first?.pair, "USDEUR")
        XCTAssertEqual(viewModel.updatedCurrencyListModelArray.first?.rate, 0.85621)
        XCTAssertEqual(viewModel.updatedCurrencyListModelArray.first?.baseRate, 0.84735)
        XCTAssertNotEqual(viewModel.updatedCurrencyListModelArray.first?.percentage, 0.0)
        XCTAssertNotNil(viewModel.updatedCurrencyListModelArray.first?.buyRate)
        XCTAssertNotNil(viewModel.updatedCurrencyListModelArray.first?.sellRate)
        XCTAssertEqual(viewModel.updatedCurrencyListModelArray.count, 7)
    }
    
    

}
