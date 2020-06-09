//
//  WalletPreviewCell.swift
//  FinanceKnight
//
//  Created by Kirill Kubarev on 25.05.2020.
//  Copyright © 2020 Kirill Kubarev. All rights reserved.
//

import UIKit
import RealmSwift

class WalletPreviewCell: UICollectionViewCell {

    static let reuseID = "WalletPreviewCell"

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var contentContainer: UIView!
    
    func configure(_ wallet: Category) {
        titleLabel.text = wallet.name
        balanceLabel.text = numberFormatter.string(from: NSNumber(value: wallet.balance))
        currencyLabel.text = wallet.icon
        contentContainer.backgroundColor = wallet.color
    }
}
