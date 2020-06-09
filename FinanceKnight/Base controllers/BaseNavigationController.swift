//
//  BaseNavigationController.swift
//  FinanceKnight
//
//  Created by Kirill Kubarev on 27.05.2020.
//  Copyright © 2020 Kirill Kubarev. All rights reserved.
//

import UIKit

class BaseNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
    }

    private func configureNavigationBar() {
        navigationBar.backgroundColor = .background
        navigationBar.tintColor = .background
        navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationBar.topItem?.backBarButtonItem?.tintColor = .black
        navigationBar.shadowImage = UIImage()
    }
    
}
