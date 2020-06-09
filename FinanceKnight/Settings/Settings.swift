//
//  Settings.swift
//  FinanceKnight
//
//  Created by Kirill Kubarev on 27.05.2020.
//  Copyright © 2020 Kirill Kubarev. All rights reserved.
//

import Foundation

fileprivate enum SettingsKey: String {
    case baseCurrency
}

struct Settings {
    
    static var baseCurrency: Currency? {
        get {
            guard let savedData = value(.baseCurrency) else { return nil }
            return try? JSONDecoder().decode(Currency.self, from: savedData)
        }
        set {
            if let encoded = try? JSONEncoder().encode(newValue) {
                set(value: encoded, for: .baseCurrency)
            }
        }
    }
    
}


fileprivate func value(_ key: SettingsKey) -> Data? {
    return UserDefaults.standard.object(forKey: key.rawValue) as? Data
}

fileprivate func set<T>(value: T?, for key: SettingsKey) {
    return UserDefaults.standard.setValue(value, forKey: key.rawValue)
}
