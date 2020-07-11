//
//  CustomUIButton.swift
//  La Esperanza
//
//  Created by Efrain Garcia Rocha on 02/07/20.
//  Copyright © 2020 Efrain Garcia Rocha. All rights reserved.
//

import UIKit

@IBDesignable
class CustomUIButton: UIButton {

    @IBInspectable var borderColor: UIColor = .blue
    @IBInspectable var borderRadius: CGFloat = 0.0
    @IBInspectable var borderWidth: CGFloat = 0.0
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        self.layer.borderColor = borderColor.cgColor
        self.layer.cornerRadius = borderRadius
        self.layer.borderWidth = borderWidth
    }
}
