//
//  WalletPreviewTableCell.swift
//  FinanceKnight
//
//  Created by Kirill Kubarev on 26.05.2020.
//  Copyright © 2020 Kirill Kubarev. All rights reserved.
//

import UIKit

class WalletPreviewTableCell: BaseTableViewCell {
    
    static let reuseID = "WalletPreviewTableCell"

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var currencyLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionEnabled = false
    }
    
}
