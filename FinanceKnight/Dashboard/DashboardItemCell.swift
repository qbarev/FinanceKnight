//
//  DashboardItemCell.swift
//  FinanceKnight
//
//  Created by Kirill Kubarev on 24.05.2020.
//  Copyright © 2020 Kirill Kubarev. All rights reserved.
//

import UIKit

class DashboardItemCell: UICollectionViewCell {
    
    static let reuseID = "DashboardItemCell"
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var iconLabel: UILabel!
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var balanceLabel: UILabel!
    
    func configure(_ category: Category) {
        titleLabel.text = category.name
        iconLabel.text = category.icon
        colorView.backgroundColor = category.color
        
        switch category.type {
        case .income:
            balanceLabel.isHidden = true
        default:
            balanceLabel.isHidden = false
            balanceLabel.text = numberFormatter.string(from: NSNumber(value: category.balance))
        }
    }
    
}
