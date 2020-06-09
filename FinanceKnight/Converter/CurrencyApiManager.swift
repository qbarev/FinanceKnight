//
//  CurrencyApiManager.swift
//  FinanceKnight
//
//  Created by Kirill Kubarev on 22.05.2020.
//  Copyright © 2020 Kirill Kubarev. All rights reserved.
//

import Foundation

protocol CurrencyDataManager {
    var base: Currency? { get set }
    var quote: Currency? { get set }
    var url: URL? { get }
    
    func getRate(completion: @escaping (FetchResult) -> Void, failed: @escaping (Any?) -> Void)
    func stopAllTasks()
}

class ExchangeRateManager: CurrencyDataManager {
    
    var url: URL? {
        guard let base = self.base else { return nil }
        guard let quote = self.quote else { return nil }
        return URL(string: "https://api.exchangeratesapi.io/latest?base=\(base.code)&symbols=\(quote.code)")
    }
    
    var base: Currency? {
        didSet {
            stopAllTasks()
        }
    }
    var quote: Currency? {
        didSet {
            stopAllTasks()
        }
    }

    private let session = URLSession(configuration: .default)
    
    init(base: Currency, quote: Currency) {
        self.base = base
        self.quote = quote
    }
    
    func getRate(completion: @escaping (FetchResult) -> Void, failed: @escaping (Any?) -> Void) {
        guard let url = self.url else {
            failed(nil)
            return
        }
        
        session.dataTask(with: url) { [unowned self] data, response, error in
            guard !error.isExist else {
                failed(error)
                return
            }
            
            guard let data = data else {
                failed(nil)
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! [String : AnyObject]
                
                guard let rates = json["rates"] as? [String : Double] else {
                    failed(nil)
                    return
                }
                
                guard let result = self.createFetchResult(rates: rates, url: url) else {
                    failed(nil)
                    return
                }
                
                completion(result)
                
            } catch( let jsonError) {
                failed(jsonError)
            }
            
            
        }.resume()
    }
    
    func stopAllTasks() {
        session.stopTasks()
    }
    
    private func createFetchResult(rates: [String : Double], url: URL) -> FetchResult? {
        guard self.url == url else { return nil }
        guard rates.count > 0 else { return nil }
        guard let base = self.base else { return nil }
        guard let quote = self.quote else { return nil }
        
        for(key, value) in rates {
            if key == quote.code {
                return FetchResult(base: base, qoute: quote, rate: value)
            }
        }
        return nil
    }
    
}

struct FetchResult {
    var base: Currency
    var qoute: Currency
    var rate: Double
}
