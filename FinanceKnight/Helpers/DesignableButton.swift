//
//  DesignableButton.swift
//  FinanceKnight
//
//  Created by Kirill Kubarev on 26.05.2020.
//  Copyright © 2020 Kirill Kubarev. All rights reserved.
//

import UIKit

@IBDesignable class DesignableButton: UIButton {
    
    override var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? backgroundColor?.withAlphaComponent(0.5) : backgroundColor?.withAlphaComponent(1.0)
        }
    }
    
    override var isSelected: Bool {
        didSet {
            backgroundColor = isSelected ? backgroundColor?.withAlphaComponent(0.5) : backgroundColor?.withAlphaComponent(1.0)
        }
    }

    //MARK: Inspectable
    @IBInspectable private var shadowColor: UIColor {
        set{
            layer.shadowColor = newValue.cgColor
        }
        get {
            UIColor(cgColor: layer.shadowColor ?? UIColor.clear.cgColor)
        }
    }
    @IBInspectable private var shadowOffset: CGSize {
        set {
            layer.shadowOffset = newValue
        }
        get {
            layer.shadowOffset
        }
    }
    @IBInspectable private var shadowRadius: CGFloat {
        set {
            layer.shadowRadius = newValue
        }
        get {
            layer.shadowRadius
        }
    }
    @IBInspectable private var shadowOpacity: Float {
        set {
            layer.shadowOpacity = newValue
        }
        get {
            layer.shadowOpacity
        }
    }
    @IBInspectable private var cornerRadius: CGFloat {
        set {
            layer.cornerRadius = newValue
        }
        get {
            layer.cornerRadius
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.shadowPath = UIBezierPath(rect: bounds).cgPath
    }
    
    @IBInspectable private var borderColor: UIColor {
        set {
            layer.borderColor = newValue.cgColor
        }
        get {
            UIColor(cgColor: layer.borderColor ?? UIColor.clear.cgColor)
        }
    }
    
    @IBInspectable private var borderWidth: CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            layer.borderWidth
        }
    }

}
