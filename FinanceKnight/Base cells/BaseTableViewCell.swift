//
//  BaseTableViewCell.swift
//  FinanceKnight
//
//  Created by Kirill Kubarev on 26.05.2020.
//  Copyright © 2020 Kirill Kubarev. All rights reserved.
//

import UIKit

class BaseTableViewCell: UITableViewCell {
    
    var contentContainer: DesignableView? {
        contentView.subviews.first(where: { $0 is DesignableView }) as? DesignableView
    }
    
    var selectionEnabled: Bool = true
    
    private var tempColor: UIColor?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        tempColor = contentContainer?.backgroundColor
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        animateContentContainer(selected)
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        animateContentContainer(highlighted)
    }
    
    //MARK: Helpers
    private func animateContentContainer(_ selected: Bool) {
        guard selectionEnabled else { return }
        guard let contentContainer = self.contentContainer else { return }
        guard let tempColor = self.tempColor else { return }
        
        if selected {
            UIView.animate(withDuration: animationDuration, animations: {
                contentContainer.backgroundColor = .selectedColor
            })
        } else {
            UIView.animate(withDuration: animationDuration, animations: {
                contentContainer.backgroundColor = tempColor
            })
        }
    }
    

}
