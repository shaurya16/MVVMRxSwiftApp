//
//  HeaderTableViewCell.swift
//  MVVMRxSwiftApp
//
//  Created by Shaurya Srivastava on 13/8/2020.
//  Copyright © 2020 Shaurya Srivastava. All rights reserved.
//

import Foundation
import UIKit

class HeaderTableViewCell: UITableViewCell {
    
    @IBOutlet weak var changeLabel: UILabel!
    @IBOutlet weak var sellLabel: UILabel!
    @IBOutlet weak var buyLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
