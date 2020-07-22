//
//  SelectProductTableViewController.swift
//  La Esperanza
//
//  Created by Efrain Garcia Rocha on 20/07/20.
//  Copyright © 2020 Efrain Garcia Rocha. All rights reserved.
//

import UIKit

class SelectProductTableViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    let webApi: WebApi = WebApi()
    let numberFormatter: NumberFormatter = NumberFormatter()
    let alerts: AlertsHelper = AlertsHelper()
    var selectedIndex: IndexPath = IndexPath()
    var productModel: ArticlesModel = ArticlesModel()
    var productsList: [ProductModel] = []
    var showProductPicker: Bool = false
    var sourceSegue: String = ""
    
    @IBOutlet var quantityTextField: ImageTextField!
    @IBOutlet var productLabel: UILabel!
    @IBOutlet var productPickerView: UIPickerView!
    @IBOutlet var productPriceTextField: ImageTextField!
    @IBOutlet var productTotalTextField: ImageTextField!
    @IBOutlet var productBottomBorder: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        numberFormatter.allowsFloats = true
        numberFormatter.minimumFractionDigits = 2
        numberFormatter.maximumFractionDigits = 2
        numberFormatter.alwaysShowsDecimalSeparator = true
        numberFormatter.generatesDecimalNumbers = true
        
        quantityTextField.addTarget(self, action: #selector(textDidChange), for: .allEditingEvents)
        productPriceTextField.addTarget(self, action: #selector(textDidChange), for: .allEditingEvents)
        productTotalTextField.addTarget(self, action: #selector(totalChanged), for: .allEditingEvents)
        
        getProducts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setToolbarHidden(true, animated: true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(quantityTextField!)
        NotificationCenter.default.removeObserver(productPriceTextField!)
        NotificationCenter.default.removeObserver(productTotalTextField!)
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return productsList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        changeProduct(row)
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return productsList[row].productName
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 && indexPath.row == 2 && !showProductPicker {
            return 0
        } else {
            return super.tableView(tableView, heightForRowAt: indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 1 {
            toggleProduct()
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    func toggleProduct() {
        showProductPicker = !showProductPicker
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    func displayInfo() {
        quantityTextField.text = numberFormatter.string(for: productModel.orderDetailQuantity)
        productLabel.text = productModel.productName
        productPriceTextField.text = numberFormatter.string(for: productModel.orderDetailPrice)
        productTotalTextField.text = numberFormatter.string(for: productModel.orderDetailTotal)
        
        if productModel.productId > 0 {
            let position = productsList.firstIndex(of: productsList.filter{$0.productId == productModel.productId}.first!)!
            productPickerView.selectRow(position, inComponent: 0, animated: false)
        }
    }
    
    func getProducts() {
       webApi.DoGet("orders/products", onCompleteHandler: {(response, error) -> Void in
            do {
                                
                guard error == nil else {
                    if (error as NSError?)?.code == 401 {
                        self.performSegue(withIdentifier: "TimeoutSegue", sender: self)
                    }
                    return
                }
                
                guard response != nil else { return }
                
                if let data = response {
                    self.productsList = try JSONDecoder().decode([ProductModel].self, from: data)
                }
                
                DispatchQueue.main.async {
                    self.productPickerView.reloadAllComponents()
                    self.displayInfo()
                }
            } catch {
                return
            }
        })
    }
    
    @objc func textDidChange() {
        let quantity = Decimal(string: quantityTextField.text ?? "1") ?? 1
        let price = Decimal(string: productPriceTextField.text ?? "0") ?? 0
        let total = quantity * price
        productTotalTextField.text = numberFormatter.string(for: total)
    }
    
    @objc func totalChanged() {
        let total = Decimal(string: productTotalTextField.text ?? "0") ?? 0
        let price = Decimal(string: productPriceTextField.text ?? "0") ?? 1
        let quantity = total / price
        quantityTextField.text = numberFormatter.string(for: quantity)
    }
       
    func changeProduct(_ row: Int) {
        let product = productsList[row]
        let quantity = Decimal(string: quantityTextField.text ?? "1")
        let total = (quantity! * product.productPrice)
        productModel.productId =  product.productId
        productLabel.text = product.productName
        productPriceTextField.text = numberFormatter.string(for: product.productPrice)
        productTotalTextField.text = numberFormatter.string(for: total)
    }
    
    func validateInputs() -> Bool {
        guard quantityTextField.text != nil else { return false }
        guard productModel.productId > 0 else { return false }
        guard productPriceTextField.text != nil else { return false }
        guard productTotalTextField.text != nil else { return false }
        return true
    }
    
    func markInvalidInputs() {
        if quantityTextField.text!.isEmpty {
            quantityTextField.setValidationError()
        } else {
            quantityTextField.clearValidationError()
        }
        
        if productTotalTextField.text!.isEmpty {
            productTotalTextField.setValidationError()
        } else {
            productTotalTextField.clearValidationError()
        }
        
        if productPriceTextField.text!.isEmpty {
            productPriceTextField.setValidationError()
        } else {
            productPriceTextField.clearValidationError()
        }
        
        if productModel.productId <= 0 {
            productBottomBorder.backgroundColor = UIColor.red
        } else{
            productBottomBorder.backgroundColor = UIColor.lightGray
        }
    }
    
    @IBAction func save(_ sender: Any) {
        if validateInputs() {
            productModel.orderDetailQuantity = Double(exactly: numberFormatter.number(from: quantityTextField.text!)!)!
            productModel.orderDetailPrice = Decimal(string: productPriceTextField.text!)!
            productModel.orderDetailTotal = Decimal(string: productTotalTextField.text!)!
            productModel.productName = productLabel.text!
            
            if sourceSegue == "SelectProduct" {
                performSegue(withIdentifier: "OrderSegue", sender: nil)
            } else {
                performSegue(withIdentifier: "UpdateSegue", sender: nil)
            }
            
        } else {
            alerts.showErrorAlert(self, message: NSLocalizedString("alert_validation_message", tableName: "messages", comment: ""), onComplete: {() -> Void in
                self.markInvalidInputs()
            })
        }
    }
}
