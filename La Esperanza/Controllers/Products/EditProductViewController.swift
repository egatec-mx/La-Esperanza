//
//  ProductViewController.swift
//  La Esperanza
//
//  Created by Efrain Garcia Rocha on 15/07/20.
//  Copyright © 2020 Efrain Garcia Rocha. All rights reserved.
//

import UIKit

class EditProductViewController: UITableViewController {
    let webApi: WebApi = WebApi()
    var productModel: ProductModel = ProductModel()
    let numberFormat: NumberFormatter = NumberFormatter()
    
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
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let productCell = cell as! ProductTableViewCell
            productCell.productName.text = self.productModel.productName
            productCell.productPrice.text = self.numberFormat.string(for: self.productModel.productPrice)
        }
    }
    
    @IBAction func update(_ sender: Any) {
        let productCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! ProductTableViewCell
        
        if productCell.productName.text!.isEmpty || productCell.productPrice.text!.isEmpty {
            
            let valAlert = UIAlertController(title: NSLocalizedString("alert_validation_title", tableName: "messages", comment: ""), message: NSLocalizedString("alert_validation_message", tableName: "messages", comment: ""), preferredStyle: .alert)
            
            valAlert.addAction(UIAlertAction(title: NSLocalizedString("alert_accept", tableName: "messages", comment: ""), style: .default, handler: nil))
            
            self.present(valAlert, animated: true, completion: {() -> Void in
                
                if productCell.productName.text!.isEmpty {
                    productCell.productName.setValidationError()
                }
                
                if productCell.productPrice.text!.isEmpty {
                    productCell.productPrice.setValidationError()
                }
                
            })
            
        } else {
            productModel.productName = productCell.productName.text!
            productModel.productPrice = numberFormat.number(from: productCell.productPrice.text!) as! Decimal
            productModel.productActive = true
            
            do {
                let data = try JSONEncoder().encode(productModel)
            
                webApi.DoPost("products/update", jsonData: data, onCompleteHandler: {(response, error) -> Void in
                                        
                    guard error == nil else {
                        if (error as NSError?)?.code == 401 {
                            self.performSegue(withIdentifier: "TimeoutSegue", sender: self)
                        }
                        return
                    }
                    
                    guard response != nil else { return }
                    
                    let successAlert = UIAlertController(title: NSLocalizedString("alert_success", tableName: "messages", comment: ""), message: NSLocalizedString("alert_product_success_edit", tableName: "messages", comment: ""), preferredStyle: .alert)
                    
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
    
    @objc func getProduct(){
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
                        self.tableView.reloadData()
                    }
                }
                
            } catch {
                return
            }
        })
    }
}
