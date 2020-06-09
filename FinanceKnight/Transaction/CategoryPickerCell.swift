//
//  CategoryPickerCell.swift
//  FinanceKnight
//
//  Created by Kirill Kubarev on 28.05.2020.
//  Copyright © 2020 Kirill Kubarev. All rights reserved.
//

import UIKit

class CategoryPickerCell: BaseTableViewCell {
    
    static let reuseID = "CategoryPickerCell"
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var iconLabel: UILabel!
    @IBOutlet weak var colorView: DesignableButton!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var disclosure: UIImageView!
    
    func configure(_ category: Category?) {
        titleLabel.text = category?.name ?? "Category"
        iconLabel.text = category?.icon ?? "❓"
        colorView.backgroundColor = category?.color ?? UIColor.gray
        
        switch category?.type {
        case .income:
            detailLabel.isHidden = true
        case .none:
            detailLabel.isHidden = true
        default:
            detailLabel.isHidden = false
            detailLabel.text = numberFormatter.string(from: NSNumber(value: category!.balance))
        }
    }
    
}
