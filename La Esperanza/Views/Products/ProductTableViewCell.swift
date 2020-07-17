//
//  ProductTableViewCell.swift
//  La Esperanza
//
//  Created by Efrain Garcia Rocha on 15/07/20.
//  Copyright © 2020 Efrain Garcia Rocha. All rights reserved.
//

import UIKit

class ProductTableViewCell: UITableViewCell, UITextFieldDelegate {
    
    @IBOutlet var productName: ImageTextField!
    @IBOutlet var productPrice: ImageTextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        productName.delegate = self
        productPrice.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == productName {
            productPrice.becomeFirstResponder()
        } else {
            productPrice.resignFirstResponder()
        }
        
        return true
    }
}
