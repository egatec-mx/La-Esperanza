//
//  ImageTextField.swift
//  La Esperanza
//
//  Created by Efrain Garcia Rocha on 16/07/20.
//  Copyright © 2020 Efrain Garcia Rocha. All rights reserved.
//

import UIKit

@IBDesignable class ImageTextField: UITextField {
    
    @IBInspectable var padding: CGFloat = 0
    @IBInspectable var imageWidth: CGFloat = 0
    
    @IBInspectable var leftImage: UIImage? {
        didSet {
            leftViewMode = .always
            leftView = UIImageView(image: leftImage)
            leftView?.contentMode = .scaleAspectFit
        }
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: padding + imageWidth, dy: padding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return textRect(forBounds: bounds)
    }
    
    override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: 0, y: 0, width: imageWidth, height: frame.height).insetBy(dx: padding, dy: padding)
    }
    
    func setValidationError() {
        layer.borderColor = UIColor.red.cgColor
        layer.borderWidth = 1
        layer.cornerRadius = 5
        layer.setNeedsDisplay()
    }
    
    func clearValidationError(){
        layer.borderColor = UIColor.clear.cgColor
        layer.borderWidth = 1
        layer.cornerRadius = 5
        layer.setNeedsDisplay()
    }
}
