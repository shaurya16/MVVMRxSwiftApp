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

class MarketsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var equityLabel: UILabel!
    @IBOutlet weak var assetLabel: UILabel!
    let disposeBag = DisposeBag()
    
    
    var viewModel = CurrencyListViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .search, target: self, action: nil)
        self.navigationItem.rightBarButtonItem?.tintColor = .white
        tableView.rx.setDelegate(self).disposed(by: disposeBag)
        setupBindings()
        viewModel.input.validate.onNext(())
    }
    
    
    func setupBindings() {
        
        viewModel
            .output
            .equityBalance
            .drive(equityLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel
            .output
            .assetBalance
            .drive(assetLabel.rx.text)
            .disposed(by: disposeBag)

        viewModel
            .output
            .currencyList
            .observeOn(MainScheduler.instance)
            .bind(to: tableView.rx.items(cellIdentifier: "customCell", cellType: ExchangeTableViewCell.self)) {  (row,item,cell) in
                    cell.percentageLabel.text = String(format: "%.3f", item.percentage)
                    cell.buyRateLabel.text = String(format: "%.4f", item.buyRate)
                    cell.sellRateLabel.text = String(format: "%.4f", item.sellRate)
                    if (item.percentage == 0) {
                        cell.trendImageView.image = nil
                        cell.percentageLabel.textColor = .white
                    } else if (item.percentage > 0){
                        cell.trendImageView.image = UIImage(named: "trendPositive")
                        cell.percentageLabel.textColor = .green
                    } else {
                        cell.trendImageView.image = UIImage(named: "trendNegative")
                        cell.percentageLabel.textColor = .red
                    }
                    let pairName = Utils.addSubstring(pair: item.pair, char: "/")
                    cell.currencySumbolLabel.text = pairName
                    cell.subTitleLabel.text = "\(pairName) : Forex"
        }.disposed(by: disposeBag)
        
        viewModel
            .output
            .error
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { value in
                print("Error value is: \(value)")
                if value {
                    let alert = UIAlertController(title: "Cannot connect to server", message: "Please check your network connection.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    self.present(alert, animated: true)
                }
        }).disposed(by: self.disposeBag)
        
    }
}

extension MarketsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard section == 0 else { return nil }
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
}

extension MarketsViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scrollViewHeight = scrollView.frame.size.height;
        let scrollContentSizeHeight = scrollView.contentSize.height;
        let scrollOffset = scrollView.contentOffset.y;

        if (scrollOffset + scrollViewHeight == scrollContentSizeHeight) {
            // then we are at the end
            print("reached bottom")
            viewModel.output.reachedBottom.onNext(true)
        }
    }
}
