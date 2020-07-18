//
//  NewProductTableViewController.swift
//  La Esperanza
//
//  Created by Efrain Garcia Rocha on 16/07/20.
//  Copyright © 2020 Efrain Garcia Rocha. All rights reserved.
//

import UIKit

class NewProductTableViewController: UITableViewController, UITextFieldDelegate {
    let webApi: WebApi = WebApi()
    var productModel: ProductModel = ProductModel()
    let numberFormat: NumberFormatter = NumberFormatter()
    
    @IBOutlet var inputProductName: ImageTextField!
    @IBOutlet var inputProductPrice: ImageTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.numberFormat.allowsFloats = true
        self.numberFormat.alwaysShowsDecimalSeparator = true
        self.numberFormat.generatesDecimalNumbers = true
        self.numberFormat.minimumFractionDigits = 2
        self.numberFormat.maximumFractionDigits = 2
        
        self.navigationController?.setToolbarHidden(true, animated: true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == inputProductName {
            inputProductPrice.becomeFirstResponder()
        } else {
            inputProductPrice.resignFirstResponder()
        }
        
        return true
    }
    
    @IBAction func save(_ sender: Any) {
        if inputProductName.text!.isEmpty || inputProductPrice.text!.isEmpty {
            
            let valAlert = UIAlertController(title: NSLocalizedString("alert_validation_title", tableName: "messages", comment: ""), message: NSLocalizedString("alert_validation_message", tableName: "messages", comment: ""), preferredStyle: .alert)
            
            valAlert.addAction(UIAlertAction(title: NSLocalizedString("alert_accept", tableName: "messages", comment: ""), style: .default, handler: nil))
            
            self.present(valAlert, animated: true, completion: {() -> Void in
                
                if self.inputProductName.text!.isEmpty {
                    self.inputProductName.setValidationError()
                }
                
                if self.inputProductPrice.text!.isEmpty {
                    self.inputProductPrice.setValidationError()
                }
                
            })
            
        } else {
            productModel.productName = inputProductName.text!
            productModel.productPrice = numberFormat.number(from: inputProductPrice.text!) as! Decimal
            productModel.productActive = true
            
            do {
                let data = try JSONEncoder().encode(productModel)
            
                webApi.DoPost("products/add", jsonData: data, onCompleteHandler: {(response, error) -> Void in
                                        
                    guard error == nil else {
                        if (error as NSError?)?.code == 401 {
                            self.performSegue(withIdentifier: "TimeoutSegue", sender: self)
                        }
                        return
                    }
                    
                    guard response != nil else { return }
                    
                    let successAlert = UIAlertController(title: NSLocalizedString("alert_success", tableName: "messages", comment: ""), message: NSLocalizedString("alert_product_success_add", tableName: "messages", comment: ""), preferredStyle: .alert)
                    
                    successAlert.addAction(UIAlertAction(title: NSLocalizedString("alert_accept", tableName: "messages", comment: ""), style: .default, handler: { (action) -> Void in
                        
                        self.performSegue(withIdentifier: "GoBackSegue", sender: self)
                        
                    }))
                    
                    self.present(successAlert, animated: true, completion: nil)
                    
                })
            } catch {
                
                return
            }
        }
    }
}
