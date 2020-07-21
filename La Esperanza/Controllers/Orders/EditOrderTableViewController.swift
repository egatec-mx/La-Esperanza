//
//  EditOrderTableViewController.swift
//  La Esperanza
//
//  Created by Efrain Garcia Rocha on 18/07/20.
//  Copyright © 2020 Efrain Garcia Rocha. All rights reserved.
//

import UIKit

class EditOrderTableViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    let webApi: WebApi = WebApi()
    let alerts: AlertsHelper = AlertsHelper()
    let dateFormatter: DateFormatter = DateFormatter()
    let numberFormatter: NumberFormatter = NumberFormatter()
    var orderModel: OrderDetailsModel = OrderDetailsModel()
    var methodOfPaymentList: [MethodOfPaymentList] = []
    var showMethodOfPaymentPicker: Bool = false
    var showDatePickerView: Bool = false
    
    @IBOutlet var customerLabel: UILabel!
    @IBOutlet var notesTextView: UITextView!
    @IBOutlet var orderScheduleDatePicker: UIDatePicker!
    @IBOutlet var orderScheduleDateLabel: UILabel!
    @IBOutlet var methodOfPaymentPickerView: UIPickerView!
    @IBOutlet var methodOfPaymentLabel: UILabel!
    @IBOutlet var orderTotalTextField: UILabel!
    @IBOutlet var orderDeliveryTaxTextField: ImageTextField!
    @IBOutlet var articlesTableView: ArticlesTableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dateFormatter.locale = Locale(identifier: "es-MX")
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        numberFormatter.numberStyle = .decimal
        numberFormatter.minimumFractionDigits = 2
        numberFormatter.maximumFractionDigits = 2
        numberFormatter.allowsFloats = true
        numberFormatter.alwaysShowsDecimalSeparator = true
        
        articlesTableView.isEditing = true
        articlesTableView.delegate = articlesTableView.self
        articlesTableView.dataSource = articlesTableView.self
        
        orderDeliveryTaxTextField.addTarget(self, action: #selector(textDidChange), for: .allEditingEvents)
        
        getMethodOfPayment()
        displayInfo()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 3 &&
            ((!showMethodOfPaymentPicker && indexPath.row == 1) ||
            (!showDatePickerView && indexPath.row == 3)) {
            return 0
        } else if indexPath.section == 1 {
            return CGFloat(orderModel.articles.count * 45)
        } else {
            return super.tableView(tableView, heightForRowAt: indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 3 && indexPath.row == 0 {
            showDatePickerView = false
            toggleMethodOfPayment()
        } else if indexPath.section == 3 && indexPath.row == 2 {
            showMethodOfPaymentPicker = false
            toggleDatePicker()
        }
    
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.orderModel.paymentMethodId = methodOfPaymentList[row].mopId
        self.methodOfPaymentLabel.text = methodOfPaymentList[row].mopDescription
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return methodOfPaymentList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return methodOfPaymentList[row].mopDescription
    }
    
    func toggleMethodOfPayment() {
        let selected = methodOfPaymentList.firstIndex(of: methodOfPaymentList.filter{ $0.mopId == orderModel.paymentMethodId}.first!)!
        methodOfPaymentPickerView.selectRow(selected, inComponent: 0, animated: false)
        showMethodOfPaymentPicker = !showMethodOfPaymentPicker
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    func toggleDatePicker() {
        if let stringDate = orderModel.orderScheduleDate {
            if let date = dateFormatter.date(from: stringDate) {
                orderScheduleDatePicker.date = date
            }
        }
        showDatePickerView = !showDatePickerView
        tableView.beginUpdates()
        tableView.endUpdates()
    }
            
    func displayInfo() {
        customerLabel.text = "\(orderModel.customerName) \(orderModel.customerLastname)"
        notesTextView.text = orderModel.orderNotes
    
        if orderModel.orderScheduleDate != nil {
            if let dTime: Date = dateFormatter.date(from: orderModel.orderScheduleDate!) {
               let printTime: DateFormatter = DateFormatter()
               printTime.timeStyle = .short
               printTime.dateFormat = "dd/MM/yyy hh:mm a"
               printTime.timeZone = TimeZone.current
               orderScheduleDateLabel.text = printTime.string(for: dTime)
            }
        } else {
            orderScheduleDateLabel.text = "N/A"
        }
        
        methodOfPaymentLabel.text = orderModel.paymentMethod
        orderTotalTextField.text = numberFormatter.string(for: orderModel.orderTotal)
        orderDeliveryTaxTextField.text = numberFormatter.string(for: orderModel.orderDeliveryTax)
        
        orderModel.articles.append(ArticlesModel())
        articlesTableView.articles = orderModel.articles
        articlesTableView.reloadData()
        articlesTableView.beginUpdates()
        articlesTableView.endUpdates()
        
    }
    
    func getMethodOfPayment() {
        webApi.DoGet("orders/mop-list", onCompleteHandler: { (response, error) -> Void in
            guard error == nil else {
                return
            }
            
            guard response != nil else { return }
            
            do {
                if let data = response {
                    self.methodOfPaymentList = try JSONDecoder().decode([MethodOfPaymentList].self, from: data)
                    self.methodOfPaymentPickerView.reloadAllComponents()
                }
            } catch {
                return
            }
        })
    }
    
    func calculateTotals() {
        var sum: Decimal = 0
        for article in orderModel.articles {
            sum += article.orderDetailTotal
        }
        sum += orderModel.orderDeliveryTax!
        let tax = sum * 0.16
        let sub = sum - tax
        orderModel.orderSubtotal = sub
        orderModel.orderTax = tax
        orderModel.orderTotal = sum
        orderTotalTextField.text = numberFormatter.string(for: sum)
    }
    
    @objc func textDidChange() {
        orderModel.orderDeliveryTax = Decimal(string: orderDeliveryTaxTextField.text ?? "0") ?? 0
        calculateTotals()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ProductSegue" {
            let view = segue.destination as! SelectProductTableViewController
            view.selectedIndex = articlesTableView.selectedIndex
            view.productModel = articlesTableView.articles[articlesTableView.selectedIndex.row]
        }
    }
    
    @IBAction func selectedDate(_ sender: UIDatePicker) {
        let dateFormat = DateFormatter()
        dateFormat.calendar = Calendar.current
        dateFormat.dateFormat = "dd/MM/yyy hh:mm a"
        dateFormat.timeZone = TimeZone.current
        orderScheduleDateLabel.text = dateFormat.string(from: orderScheduleDatePicker.date)
        orderModel.orderScheduleDate = dateFormatter.string(from: orderScheduleDatePicker.date)
    }
    
    @IBAction func updateOrder(_ sender: Any) {
        do {
            self.showWait()
            
            orderModel.orderNotes = notesTextView.text
            
            let data = try JSONEncoder().encode(orderModel)
            
            webApi.DoPost("orders/update", jsonData: data, onCompleteHandler: {(response, error) -> Void in
                
                guard error == nil else {
                    if (error as NSError?)?.code == 401 {
                        self.hideWait()
                        self.performSegue(withIdentifier: "TimeoutSegue", sender: self)
                    }
                    return
                }
                
                guard response != nil else { return }
                
                if let data = response {
                    self.hideWait()
                    
                    self.orderModel = try! JSONDecoder().decode(OrderDetailsModel.self, from: data)
                    
                    if self.orderModel.errors.count > 0 {
                        self.alerts.processErrors(self, errors: self.orderModel.errors)
                    }
                    
                    if !self.orderModel.message.isEmpty {
                        self.alerts.showSuccessAlert(self, message: self.orderModel.message, onComplete: {() -> Void in
                            self.performSegue(withIdentifier: "GoBackSegue", sender: self)
                        })
                    }
                }
            })
        } catch {
            return
        }
    }
    
    @IBAction func unwindSegue(_ segue: UIStoryboardSegue) {
        if segue.identifier == "UpdateSegue" {
            let source = segue.source as! SelectProductTableViewController
            
            articlesTableView.beginUpdates()
            articlesTableView.articles[source.selectedIndex.row] = source.productModel
            articlesTableView.reloadData()
            articlesTableView.endUpdates()
            
            tableView.beginUpdates()
            orderModel.articles = articlesTableView.articles
            tableView.reloadData()
            tableView.endUpdates()
            
            calculateTotals()
        }
    }
}
