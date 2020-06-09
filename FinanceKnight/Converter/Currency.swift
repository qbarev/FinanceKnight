//
//  Currency.swift
//  FinanceKnight
//
//  Created by Kirill Kubarev on 22.05.2020.
//  Copyright © 2020 Kirill Kubarev. All rights reserved.
//

import Foundation

struct CurrencyList {
    
    static let shared = CurrencyList()
    
    let currencies =   [Currency(code: "USD", name: "US dollar", symbol: "$"),
                        Currency(code: "RUB", name: "Russian rouble", symbol: "₽"),
                        Currency(code: "EUR", name: "EURO", symbol: "€"),
                        Currency(code: "JPY", name: "Japanese yen", symbol: "¥"),
                        Currency(code: "GBP", name: "Pound sterling", symbol: "£"),
                        Currency(code: "CAD", name: "Canadian dollar", symbol: "C$"),
                        Currency(code: "AUD", name: "Australian dollar", symbol: "A$"),
                        Currency(code: "MYR", name: "Malaysian ringgit", symbol: "RM"),
                        Currency(code: "BGN", name: "Bulgarian lev", symbol: "лв"),
                        Currency(code: "CZK", name: "Czech koruna", symbol: "Kč"),
                        Currency(code: "RON", name: "Romanian leu", symbol: "lei"),
                        Currency(code: "CHF", name: "Swiss franc", symbol: "CHF"),
                        Currency(code: "PLN", name: "Polish zloty", symbol: "zł"),
                        Currency(code: "IDR", name: "Indonesian rupiah", symbol: "Rp"),
                        Currency(code: "NZD", name: "New Zealand dollar PHP Philippine peso", symbol: "$"),
                        Currency(code: "ILS", name: "Israeli shekel", symbol: "₪"),
                        Currency(code: "SGD", name: "Singapore dollar", symbol: "$"),
                        Currency(code: "ISK", name: "Icelandic krona", symbol: "kr"),
                        Currency(code: "DKK", name: "Danish krone", symbol: "kr"),
                        Currency(code: "HRK", name: "Croatian kuna", symbol: "kn"),
                        Currency(code: "KRW", name: "South Korean won MXN Mexican peso", symbol: "₩"),
                        Currency(code: "ZAR", name: "South African rand", symbol: "R"),
                        Currency(code: "TRY", name: "Turkish lira", symbol: "₺"),
                        Currency(code: "BRL", name: "Brazilian real", symbol: "R$"),
                        Currency(code: "SEK", name: "Swedish krona", symbol: "kr"),
                        Currency(code: "CNY", name: "Chinese yuan renminbi HKD Hong Kong dollar", symbol: "¥"),
                        Currency(code: "INR", name: "Indian rupee", symbol: "₹"),
                        Currency(code: "NOK", name: "Norwegian krone", symbol: "kr"),
                        Currency(code: "THB", name: "Thai baht", symbol: "฿"),
                        Currency(code: "HUF", name: "Hungarian forint", symbol: "Ft")]
    
    subscript(code: String) -> Currency? {
        currencies.first(where: { $0.code == code })
    }
    
    private init() {}
    
}

struct Currency: Codable {
    let code: String
    let name: String
    let symbol: String 
}

extension Currency: Equatable {
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.code == rhs.code
    }
    
}
