//
//  String .swift
//  FinanceKnight
//
//  Created by Kirill Kubarev on 27.05.2020.
//  Copyright © 2020 Kirill Kubarev. All rights reserved.
//

import Foundation

extension String {
    
    mutating func replaceLastCharacter(_ character: Character, toValue value: Character) {
        if let lastIndex = lastIndex(of: character) {
            remove(at: lastIndex)
            append(value)
        }
    }
    
}
