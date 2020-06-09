//
//  Category.swift
//  FinanceKnight
//
//  Created by Kirill Kubarev on 22.05.2020.
//  Copyright © 2020 Kirill Kubarev. All rights reserved.
//

import UIKit
import RealmSwift

@objcMembers class Category: Object, RepositoryEntity {
    dynamic var id = UUID().uuidString
    dynamic var typeData = 0
    dynamic var colorData = Data()
    dynamic var currencyData = Data()
    dynamic var name = "Name"
    dynamic var icon: String? = nil
    dynamic var date = Date()
    
    var balance: Double {
        incomingsLinking.sum(ofProperty: "amount") - outcomingsLinking.sum(ofProperty: "amount")
    }
    
    let outcomingsLinking = LinkingObjects(fromType: Transaction.self, property: "source")
    let incomingsLinking = LinkingObjects(fromType: Transaction.self, property: "destination")
    
    override class func primaryKey() -> String? {
        "id"
    }
}

//MARK: Setters & Getters
extension Category {
    
    var type: CategoryType? {
        get {
            CategoryType(rawValue: typeData)
        }
        set {
            guard let typeInt = newValue?.rawValue else { return }
            
            self.typeData = typeInt
        }
    }
    
    var color: UIColor? {
        get {
            try? UIColor.color(fromData: colorData)
        }
        set {
            guard let colorData = try? newValue?.encode() else { return }
            
            self.colorData = colorData
        }
    }
    
    var currency: Currency? {
        get {
            try? JSONDecoder().decode(Currency.self, from: currencyData)
        }
        set {
            guard let currencyData = try? JSONEncoder().encode(newValue) else { return }
            
            self.currencyData = currencyData
        }
    }
    
    var incomings: [Transaction] {
        Array(incomingsLinking)
    }
    var outcomings: [Transaction] {
        Array(outcomingsLinking)
    }

}

//MARK: Types
enum CategoryType: Int {
    case wallet = 0
    case income
    case expense
    
    var color: UIColor? {
        switch self {
        case .income:
            return .income
        case .expense:
            return .expense
        default:
            return nil
        }
    }
    
    var icon: String? {
        switch self {
        case .income:
            return "🍏"
        case .expense:
            return "🍎"
        default:
            return nil
        }
    }
    
    var defaultName: String {
        switch self {
        case .wallet:
            return "Wallet"
        case .income:
            return "Income"
        case .expense:
            return "Expense"
        }
    }
    
    var predicate: NSPredicate {
        NSPredicate(format: "typeData == \(rawValue)")
    }
    
}

