//
//  TransactionCell.swift
//  FinanceKnight
//
//  Created by Kirill Kubarev on 26.05.2020.
//  Copyright © 2020 Kirill Kubarev. All rights reserved.
//

import UIKit

class TransactionCell: UITableViewCell {
    
    static let reuseID = "TransactionCell"

    @IBOutlet weak var activityIndicatior: UIActivityIndicatorView!
    @IBOutlet weak var titleStack: UIStackView!
    @IBOutlet weak var amountStack: UIStackView!
    
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    
    @IBOutlet weak var iconView: DesignableView!
    @IBOutlet weak var iconLabel: UILabel!
    @IBOutlet weak var disclosure: UIImageView!
    
    func configureWithTransaction(_ transaction: Transaction) {
        titleLabel.text = transaction.destination?.name
        subtitleLabel.text = transaction.source?.name
        
        let currencySymbol = transaction.currency?.symbol ?? ""
        let amountString = numberFormatter.string(from: NSNumber(value: transaction.amount)) ?? "0"
        detailLabel.textColor = transaction.type?.color
        detailLabel.text = currencySymbol + " " + amountString
        
        iconView.backgroundColor = transaction.destination?.color
        iconLabel.text = transaction.destination?.icon
    }
    
}
