//
//  FixedLengthTextField.swift
//  La Esperanza
//
//  Created by Efrain Garcia Rocha on 18/07/20.
//  Copyright © 2020 Efrain Garcia Rocha. All rights reserved.
//

import UIKit

@IBDesignable class FixedLengthTextField: ImageTextField {
    @IBInspectable var onlyDigits: Bool = false
    @IBInspectable var length: Int = Int.max
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.addNotification()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.addNotification()
    }
    
    func addNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(textDidChange), name: UITextField.textDidChangeNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func textDidChange() {
        var temp = text!
        
        if onlyDigits && length == Int.max {
            temp = temp.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
            text = temp
        }
        
        if onlyDigits && length < Int.max {
            temp = temp.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
            var fixedString = ""
            var stop = false
            var idx = 0
            
            while !stop {
                if temp.count > 0 {
                    fixedString += String(temp[idx])
                    idx += 1
                    if idx >= length || idx >= temp.count {
                        stop = true
                    }
                } else {
                    stop = true
                }
            }
            
            text = fixedString
        }
        
    }
}
