//
//  MVVMRxSwiftAppTests.swift
//  MVVMRxSwiftAppTests
//
//  Created by Shaurya Srivastava on 10/8/2020.
//  Copyright © 2020 Shaurya Srivastava. All rights reserved.
//

import XCTest
import RxSwift

@testable import MVVMRxSwiftApp

class MVVMRxSwiftAppTests: XCTestCase {
    
    var viewModel: CurrencyListViewModel!
    
    override func setUp() {
        let mockViewModel = CurrencyListViewModel(currencyService: MockCurrencyService())
        self.viewModel = mockViewModel
    }

    func test_ViewModel_FetchData() {
        viewModel.output.currencyList.share().subscribe(onNext: { (array) in
            _ = array.map({ print($0)})
        }).disposed(by: DisposeBag())
    }
    

}
