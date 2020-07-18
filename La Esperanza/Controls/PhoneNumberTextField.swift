//
//  MaskedTextField.swift
//  La Esperanza
//
//  Created by Efrain Garcia Rocha on 18/07/20.
//  Copyright © 2020 Efrain Garcia Rocha. All rights reserved.
//

import UIKit

@IBDesignable class PhoneNumberTextField: ImageTextField {
    @IBInspectable var textMask: String = ""
    @IBInspectable var replaceChar: String = ""
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.addNotification()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addNotification()
    }
    
    func addNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(textDidChange), name: NSNotification.Name("UITextFieldTextDidChangeNotification"), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func textDidChange() {
        
        if text!.count > 0 && textMask.count > 0 {
            
            let numbers = unMaskValue()
            var masked = ""
            var stop = false
            var i = 0, j = 0
            
            while !stop {
                
                if String(textMask[i]) != String(replaceChar) {
                    masked += String(textMask[i])
                } else if numbers.count > 0 {
                    masked += String(numbers[j])
                    j += 1
                }
                
                i += 1
                
                if j >= numbers.count || i >= textMask.count {
                    stop = true
                }
            }
            
            text = masked
        }
    }
    
    func unMaskValue() -> String {
        return text!.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
    }
}
