//
//  Transaction.swift
//  FinanceKnight
//
//  Created by Kirill Kubarev on 22.05.2020.
//  Copyright © 2020 Kirill Kubarev. All rights reserved.
//

import UIKit
import RealmSwift

@objcMembers class Transaction: Object, RepositoryEntity {
    dynamic var id = UUID().uuidString
    
    dynamic var typeData = 0
    dynamic var amount: Double = 0
    dynamic var date = Date()
    dynamic var comment: String? = nil
    dynamic var currencyData: Data? = try? JSONEncoder().encode(Settings.baseCurrency)
    
    dynamic var source: Category?
    dynamic var destination: Category?
    
    override class func primaryKey() -> String? {
        "id"
    }
    
}

//MARK: Getters & Setters
extension Transaction {

    var type: TransactionType? {
        get {
            TransactionType(rawValue: typeData)
        }
        set {
            typeData = newValue?.rawValue ?? 0
        }
    }
    
    var currency: Currency? {
        guard let currencyData = self.currencyData else { return nil }
        return try? JSONDecoder().decode(Currency.self, from: currencyData)
    }
    
}

//MARK: Types
enum TransactionType: Int {
    case income = 0
    case expense
    case transfer
    
    var color: UIColor {
        switch self {
        case .income:
            return .income
        case .expense:
            return .expense
        case .transfer:
            return .black
        }
    }
    
    var defaultSource: Category? {
        let categoryRepository = AnyRepository<Category>()
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        
        switch self {
        case .income:
            return categoryRepository.fetch(predicate: CategoryType.income.predicate, sortDescriptor: sortDescriptor)?.first
        default:
            return categoryRepository.fetch(predicate: CategoryType.wallet.predicate, sortDescriptor: sortDescriptor)?.first
        }
    }
    
    var defaultDestination: Category? {
        let categoryRepository = AnyRepository<Category>()
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        
        switch self {
        case.expense:
            return categoryRepository.fetch(predicate: CategoryType.expense.predicate, sortDescriptor: sortDescriptor)?.first
        default:
            return categoryRepository.fetch(predicate: CategoryType.wallet.predicate, sortDescriptor: sortDescriptor)?.first
        }
    }
}
