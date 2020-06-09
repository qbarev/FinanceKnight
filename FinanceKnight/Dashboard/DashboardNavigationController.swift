//
//  DashboardNavigationController.swift
//  FinanceKnight
//
//  Created by Kirill Kubarev on 09.06.2020.
//  Copyright © 2020 Kirill Kubarev. All rights reserved.
//

import UIKit

class DashboardNavigationController: BaseNavigationController {
    
    private var transactionButton : UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTransactionButton()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        transactionButton.layer.shadowColor = UIColor.primary.cgColor
        transactionButton.layer.shadowOffset = shadowOffset
        transactionButton.layer.shadowRadius = shadowRadius
        transactionButton.layer.shadowOpacity = shadowOpacity
    }
    
    @objc private func addTransaction() {
        performSegue(withIdentifier: transactionEditing, sender: nil)
    }
    
    private func configureTransactionButton() {
        transactionButton = UIButton(type: .custom)
        let buttonImage = #imageLiteral(resourceName: "AddTransactionButton")
        let selectedButtonImage = #imageLiteral(resourceName: "AddTransactionButtonSelected")
        
        transactionButton.setImage(buttonImage, for: .normal)
        transactionButton.setImage(selectedButtonImage, for: .highlighted)
        transactionButton.addTarget(self, action: #selector(addTransaction), for: .touchUpInside)

        view.addSubview(transactionButton)
        
        transactionButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            transactionButton.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor),
            view.layoutMarginsGuide.bottomAnchor.constraint(equalTo: transactionButton.bottomAnchor),
            transactionButton.heightAnchor.constraint(equalToConstant: transactionButtonHeight),
            transactionButton.widthAnchor.constraint(equalToConstant: transactionButtonWidth)
        ])
    }
}
