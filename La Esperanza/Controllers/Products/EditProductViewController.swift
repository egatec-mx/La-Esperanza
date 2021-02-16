//
//  ProductViewController.swift
//  La Esperanza
//
//  Created by Efrain Garcia Rocha on 15/07/20.
//  Copyright © 2020 Efrain Garcia Rocha. All rights reserved.
//

import UIKit

class EditProductViewController: UITableViewController, UITextFieldDelegate {
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
        
        self.getProduct()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == inputProductName {
            inputProductPrice.becomeFirstResponder()
        } else {
            inputProductPrice.resignFirstResponder()
        }
        
        return true
    }
    
    @IBAction func update(_ sender: Any) {
        if inputProductName.text!.isEmpty || inputProductPrice.text!.isEmpty {
            
            self.alerts.showErrorAlert(self, message: NSLocalizedString("alert_validation_message", tableName: "messages" , comment: ""), delay: false, onComplete: {() -> Void in
                
                if self.inputProductName.text!.isEmpty {
                    self.inputProductName.setValidationError()
                }
                
                if self.inputProductPrice.text!.isEmpty {
                    self.inputProductPrice.setValidationError()
                }
            })
            
        } else {
            self.showWait({ [self] () -> Void in
                productModel.productName = inputProductName.text!
                productModel.productPrice = numberFormat.number(from: inputProductPrice.text!) as! Decimal
                productModel.productActive = true
                
                do {
                    let data = try JSONEncoder().encode(productModel)
                
                    webApi.DoPost("products/update", jsonData: data, onCompleteHandler: {(response, error) -> Void in
                        guard error == nil else {
                            if (error as NSError?)?.code == 401 {
                                performSegue(withIdentifier: "TimeoutSegue", sender: self)
                            }
                            return
                        }
                        
                        guard response != nil else { return }
                        
                        if let data = response {
                            productModel = try! JSONDecoder().decode(ProductModel.self, from: data)
                        }
                        
                        hideWait()
                        
                        if productModel.errors.count > 0 {
                            alerts.processErrors(self, errors: productModel.errors)
                        }
                        
                        if !productModel.message.isEmpty {
                            alerts.showSuccessAlert(self, message: productModel.message, onComplete: {() -> Void in
                                performSegue(withIdentifier: "GoBackSegue", sender: self)
                            })
                        }
                                                                    
                    })
                } catch {
                    
                    return
                }
            })
            
        }
    }
    
    @objc func getProduct() {
        webApi.DoGet("products/\(productModel.productId)", onCompleteHandler: { (response, error) -> Void in
            do {
                guard error == nil else {
                    if (error as NSError?)?.code == 401 {
                        self.performSegue(withIdentifier: "TimeoutSegue", sender: self)
                    }
                    return
                }
                
                guard response != nil else { return }
                
                if let data = response {
                    self.productModel = try JSONDecoder().decode(ProductModel.self, from: data)
                    
                    DispatchQueue.main.async {
                        self.inputProductPrice.text = self.numberFormat.string(for: self.productModel.productPrice)
                        self.inputProductName.text = self.productModel.productName
                    }
                }
                
            } catch {
                return
            }
        })
    }
}
