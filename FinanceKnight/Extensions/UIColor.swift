//
//  UIColor.swift
//  FinanceKnight
//
//  Created by Kirill Kubarev on 22.05.2020.
//  Copyright © 2020 Kirill Kubarev. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    
    static let cellColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    static let selectedColor = #colorLiteral(red: 0.8588235294, green: 0.8588235294, blue: 0.8588235294, alpha: 1)
    static let background = #colorLiteral(red: 0.9725490196, green: 0.9725490196, blue: 0.9725490196, alpha: 1)
    static let primary = #colorLiteral(red: 0.3529411765, green: 0.4235294118, blue: 0.8862745098, alpha: 1)
    static let secondary = #colorLiteral(red: 0.8588235294, green: 0.8588235294, blue: 0.8588235294, alpha: 1)
    
    static let income = #colorLiteral(red: 0.09803921569, green: 0.7764705882, blue: 0.4117647059, alpha: 1)
    static let expense = #colorLiteral(red: 1, green: 0.4431372549, blue: 0.4431372549, alpha: 1)
    
    func encode() throws -> Data? {
        do {
            return try NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: false)
        } catch {
            throw error
        }
    }
    
    class func color(fromData data: Data) throws -> UIColor? {
        do {
            let color = try NSKeyedUnarchiver.unarchivedObject(ofClasses: [UIColor.self], from: data) as? UIColor
            return color
        } catch {
            throw error
        }
    }
    
}


