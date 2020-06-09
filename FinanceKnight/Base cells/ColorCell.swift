//
//  ColorCell.swift
//  FinanceKnight
//
//  Created by Kirill Kubarev on 26.05.2020.
//  Copyright © 2020 Kirill Kubarev. All rights reserved.
//

import UIKit

class ColorCell: BaseTableViewCell {
    
    static let reuseID = "ColorCell"
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var colorView: DesignableView!
    @IBOutlet weak var disclosure: UIImageView!
    
}
