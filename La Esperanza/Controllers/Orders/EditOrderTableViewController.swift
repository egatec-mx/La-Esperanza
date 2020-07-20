//
//  EditOrderTableViewController.swift
//  La Esperanza
//
//  Created by Efrain Garcia Rocha on 18/07/20.
//  Copyright © 2020 Efrain Garcia Rocha. All rights reserved.
//

import UIKit

class EditOrderTableViewController: UITableViewController, UIPickerViewDelegate {
    let webApi: WebApi = WebApi()
    let dateFormatter: DateFormatter = DateFormatter()
    let numberFormatter: NumberFormatter = NumberFormatter()
    var orderModel: OrderDetailsModel = OrderDetailsModel()    
    
    @IBOutlet var customerLabel: UILabel!
    @IBOutlet var notesTextView: UITextView!
    @IBOutlet var orderScheduleDatePicker: UIDatePicker!
    @IBOutlet var orderScheduleDateLabel: UILabel!
    @IBOutlet var methodOfPaymentPickerView: UIPickerView!
    @IBOutlet var methodOfPaymentLabel: UILabel!
    @IBOutlet var orderTotalTextField: UILabel!
    @IBOutlet var orderDeliveryTaxTextField: ImageTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dateFormatter.locale = Locale.current
        dateFormatter.calendar = Calendar.current
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        numberFormatter.numberStyle = .decimal
        numberFormatter.minimumFractionDigits = 2
        numberFormatter.maximumFractionDigits = 2
        numberFormatter.allowsFloats = true
        numberFormatter.alwaysShowsDecimalSeparator = true
        
        tableView.isEditing = true
        
        displayInfo()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 3 && (indexPath.row == 1 || indexPath.row == 3) {
            return 0
        } else {
            return super.tableView(tableView, heightForRowAt: indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section != 1 {
            return false
        } else {
            return true
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
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
        
    }
    
    @IBAction func unwindSegue(_ segue: UIStoryboardSegue) {
        
    }
}
