//
//  DetailCell.swift
//  FinanceKnight
//
//  Created by Kirill Kubarev on 26.05.2020.
//  Copyright © 2020 Kirill Kubarev. All rights reserved.
//

import UIKit

class DetailCell: BaseTableViewCell {
    
    static let reuseID = "DetailCell"

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var disclosure: UIImageView!
    
}
