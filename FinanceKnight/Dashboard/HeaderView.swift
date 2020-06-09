//
//  HeaderView.swift
//  FinanceKnight
//
//  Created by Kirill Kubarev on 25.05.2020.
//  Copyright © 2020 Kirill Kubarev. All rights reserved.
//

import UIKit

class HeaderView: UICollectionReusableView {
    
    static let reuseID = "HeaderView"
    
    var titleLabel: UILabel!
    var addButton: UIButton!
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        titleLabel = UILabel()
        titleLabel.font = .systemFont(ofSize: 24.0, weight: .bold)
        
        addButton = UIButton()
        addButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .light)
        addButton.setTitle("Add", for: .normal)
        addButton.setTitleColor(.blue, for: .normal)
        
        addSubview(titleLabel)
        addSubview(addButton)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            addButton.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            addButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor)
        ])
    }
}
