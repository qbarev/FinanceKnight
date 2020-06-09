//
//  URLSession.swift
//  FinanceKnight
//
//  Created by Kirill Kubarev on 22.05.2020.
//  Copyright © 2020 Kirill Kubarev. All rights reserved.
//

import Foundation

extension URLSession {

    func stopTasks() {
        getAllTasks(completionHandler: { $0.forEach( { $0.cancel() } ) })
    }
    
}
