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
    
    @IBInspectable var borderColor: UIColor = .black {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 1 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var borderRadius: CGFloat = 5 {
        didSet {
            layer.cornerRadius = borderRadius
        }
    }
    
    @IBInspectable var placeHolderColor: UIColor = .gray {
        didSet {
            attributedPlaceholder = NSAttributedString(string: placeholder ?? "", attributes: [NSAttributedString.Key.foregroundColor : placeHolderColor])
        }
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: padding + imageWidth, dy: padding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return textRect(forBounds: bounds)
    }
    
    override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: padding, y: 0, width: imageWidth, height: frame.height).insetBy(dx: padding / 2, dy: padding / 2)
    }
    
    func setValidationError() {
        layer.borderColor = UIColor.red.cgColor
        layer.setNeedsDisplay()
    }
    
    func clearValidationError(){
        layer.borderColor = borderColor.cgColor
        layer.setNeedsDisplay()
    }
}
