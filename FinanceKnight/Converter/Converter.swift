//
//  Converter.swift
//  FinanceKnight
//
//  Created by Kirill Kubarev on 22.05.2020.
//  Copyright © 2020 Kirill Kubarev. All rights reserved.
//

import Foundation

class Converter {
    
    var base: Currency {
        didSet {
            currencyDataManager.base = self.base
        }
    }
    var quote: Currency {
        didSet {
            currencyDataManager.quote = self.quote
        }
    }

    lazy private var currencyDataManager: CurrencyDataManager = ExchangeRateManager(base: self.base, quote: self.quote)
    
    init(base: Currency, quote: Currency) {
        self.base = base
        self.quote = quote
    }
    
    func convert(amount: Double, completion: @escaping ([String : Double]) -> Void, failed: @escaping () -> Void) {
        currencyDataManager.stopAllTasks()
    
        currencyDataManager.getRate(completion: { [unowned self] fetchResult in
            var result = [String : Double]()
            if fetchResult.base.code == self.base.code {
                result[fetchResult.qoute.code] = amount * fetchResult.rate
            }
            completion(result)
            }
            , failed: {_ in
                failed()
        })
    }
    
}
