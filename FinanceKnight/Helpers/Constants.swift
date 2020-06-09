//
//  Constants.swift
//  FinanceKnight
//
//  Created by Kirill Kubarev on 24.05.2020.
//  Copyright © 2020 Kirill Kubarev. All rights reserved.
//

import UIKit
import RealmSwift

//MARK: Helpers
let numberFormatter: NumberFormatter = {
    let numberFormatter = NumberFormatter()
    numberFormatter.numberStyle = .decimal
    numberFormatter.maximumFractionDigits = 2
    numberFormatter.groupingSeparator = " "
    return numberFormatter
}()

let dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "dd.MM.yyyy"
    return dateFormatter
}()

//MARK: UI
let cornerRadius: CGFloat = 10.0

let dashboardCategoryItemWidth: CGFloat = 96.0
let dashboardCategoryItemHeight: CGFloat = 145.0
let dashboardSectionHeaderHeight: CGFloat = 72.0
let transactionButtonHeight: CGFloat = 56.0
let transactionButtonWidth = transactionButtonHeight

let shadowOffset = CGSize(width: 0.0, height: 10.0)
let shadowRadius: CGFloat = 10.0
let shadowOpacity: Float = 0.5

let animationDuration: Double = 0.5

//MARK: Segue
let walletSettings = "WalletSettings"
let categorySettings = "CategorySettings"
let transactionEditing = "TransactionEditing"
let categoryOverview = "CategoryOverview"

let currencyPicker = "CurrencyPicker"
let colorPicker = "ColorPicker"
let iconPicker = "IconPicker"
let categoriesPicker = "CategoryPicker"

//MARK: Identifiers
let headerViewKind = "Header"
