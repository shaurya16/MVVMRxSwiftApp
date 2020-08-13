//
//  MarketsViewController.swift
//  MVVMRxSwiftApp
//
//  Created by Shaurya Srivastava on 10/8/2020.
//  Copyright © 2020 Shaurya Srivastava. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class MarketsViewController: UIViewController, UIScrollViewDelegate, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var equityLabel: UILabel!
    @IBOutlet weak var assestLabel: UILabel!
    let disposeBag = DisposeBag()
    
    
    var currencyListViewModel = CurrencyListViewModel()
    public var currencyList = PublishSubject<[CurrencyListModel]>()
    public var equityBalance = PublishSubject<String?>()
    public var assestBalance = PublishSubject<String?>()
    
    override func viewDidLoad() {
        self.navigationController?.title = "Markets"
        self.navigationController?.navigationItem.title = "Markets"
        tableView.rx.setDelegate(self).disposed(by: disposeBag)
        setupBindings()
        currencyListViewModel.fetchData()
        
        
        Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(updateViewModel), userInfo: nil, repeats: true)
    }
    
    
    func setupBindings() {
        
        currencyListViewModel
            .equityBalance
            .observeOn(MainScheduler.instance)
            .bind(to: equityBalance)
            .disposed(by: disposeBag)
        
        equityBalance
            .bind(to: equityLabel.rx.text)
            .disposed(by: disposeBag)
        
        currencyListViewModel
            .assestBalance
            .observeOn(MainScheduler.instance)
            .bind(to: assestBalance)
            .disposed(by: disposeBag)
        
        
        assestBalance
            .bind(to: assestLabel.rx.text)
            .disposed(by: disposeBag)
        
        currencyListViewModel
            .currencyList
            .observeOn(MainScheduler.instance)
            .bind(to: currencyList)
            .disposed(by: disposeBag)
        
        
        currencyList.bind(to: tableView.rx.items(cellIdentifier: "customCell", cellType: ExchangeTableViewCell.self)) {  (row,item,cell) in
            cell.percentageLabel.text = String(format: "%.3f", item.percentage)
            cell.buyRateLabel.text = String(format: "%.4f", item.buyRate)
            cell.sellRateLabel.text = String(format: "%.4f", item.sellRate)
            if (item.percentage == 0) {
                cell.trendImageView.image = nil
                cell.percentageLabel.textColor = .black
            } else if (item.percentage > 0){
                cell.trendImageView.image = UIImage(named: "trendPositive")
                cell.percentageLabel.textColor = .green
            } else {
                cell.trendImageView.image = UIImage(named: "trendNegative")
                cell.percentageLabel.textColor = .red
            }
            let pairName = self.addSubstring(pair: item.pair, char: "/")
            cell.currencySumbolLabel.text = pairName
            cell.subTitleLabel.text = "\(pairName) : Forex"
        }.disposed(by: disposeBag)
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerCell = tableView.dequeueReusableCell(withIdentifier: "customCell2") as? ExchangeTableViewCell else {
            return UIView()
        }
        headerCell.currencySumbolLabel.text = "Symbol"
        headerCell.percentageLabel.text = "Change"
        headerCell.sellRateLabel.text = "Sell"
        headerCell.buyRateLabel.text = "Buy"
        headerCell.backgroundColor = .white
        return headerCell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scrollViewHeight = scrollView.frame.size.height;
        let scrollContentSizeHeight = scrollView.contentSize.height;
        let scrollOffset = scrollView.contentOffset.y;

        if (scrollOffset + scrollViewHeight == scrollContentSizeHeight) {
            // then we are at the end
            print("reached bottom")
            currencyListViewModel.showCount += 20
            currencyListViewModel.fetchNextBatch()
        }
    }
    
    @objc func updateViewModel() {
        self.currencyListViewModel.update()
    }
    
    func addSubstring(pair: String, char: Character) -> String {
        var updatedPair = pair
        updatedPair.insert(char, at: pair.index(pair.startIndex, offsetBy: 3))
        return updatedPair
    }

}
