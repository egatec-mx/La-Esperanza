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
    let alerts: AlertsHelper = AlertsHelper()
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
            
            self.alerts.showErrorAlert(self, message: NSLocalizedString("alert_validation_message", tableName: "messages" , comment: ""), onComplete: {() -> Void in
                
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
                    
                    if let data = response {
                        self.productModel = try! JSONDecoder().decode(ProductModel.self, from: data)
                        
                        if self.productModel.errors.count > 0 {
                            self.alerts.processErrors(self, errors: self.productModel.errors)
                        }
                        
                        if !self.productModel.message.isEmpty {
                            self.alerts.showSuccessAlert(self, message: self.productModel.message, onComplete: {() -> Void in
                                self.performSegue(withIdentifier: "GoBackSegue", sender: self)
                            })
                        }
                    }
                    
                })
            } catch {
                
                return
            }
        }
    }
}
