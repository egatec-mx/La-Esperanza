//
//  EditCustomerTableViewController.swift
//  La Esperanza
//
//  Created by Efrain Garcia Rocha on 18/07/20.
//  Copyright © 2020 Efrain Garcia Rocha. All rights reserved.
//

import UIKit

class EditCustomerTableViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    let webApi: WebApi = WebApi()
    let alerts: AlertsHelper = AlertsHelper()
    var customerModel: CustomerModel = CustomerModel()
    var statesList: [StatesList] = []
    
    @IBOutlet var customerName: ImageTextField!
    @IBOutlet var customerLastname: ImageTextField!
    @IBOutlet var customerPhone: PhoneNumberTextField!
    @IBOutlet var customerMail: ImageTextField!
    @IBOutlet var customerStreet: ImageTextField!
    @IBOutlet var customerColony: ImageTextField!
    @IBOutlet var customerCity: ImageTextField!
    @IBOutlet var customerStatePickerView: UIPickerView!
    @IBOutlet var customerZipcode: FixedLengthTextField!
    @IBOutlet var saveButton: RoundedUIButton!
    @IBOutlet var statePickerBorder: UIVisualEffectView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.setToolbarHidden(true, animated: true)
        
        self.getStatesList()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return statesList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        customerModel.stateId = statesList[row].stateId
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return statesList[row].stateName
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case customerName:
            customerLastname.becomeFirstResponder()
        case customerLastname:
            customerPhone.becomeFirstResponder()
        case customerPhone:
            customerMail.becomeFirstResponder()
        case customerMail:
            customerStreet.becomeFirstResponder()
        case customerStreet:
            customerColony.becomeFirstResponder()
        case customerColony:
            customerCity.becomeFirstResponder()
        case customerCity:
            customerStatePickerView.becomeFirstResponder()
        case customerZipcode:
            customerZipcode.resignFirstResponder()
        default:
            return true
        }
        return true
    }
    
    @IBAction func hideKeyboard(_ sender: Any) {
        view.endEditing(true)
    }
    
    func getStatesList() {
        webApi.DoGet("customers/states-list", onCompleteHandler: {(response, error) -> Void in
            do {
                guard error == nil else {
                    if (error as NSError?)?.code == 401 {
                        self.performSegue(withIdentifier: "TimeoutSegue", sender: self)
                    }
                    return
                }
                
                guard response != nil else { return }
                
                if let data = response {
                    self.statesList = try JSONDecoder().decode([StatesList].self, from: data)
                }
                
                DispatchQueue.main.async {
                    self.customerStatePickerView.reloadAllComponents()
                    self.getCustomer()
                }
            } catch {
                return
            }
        })
    }
    
    func getCustomer() {
        self.showWait()
        webApi.DoGet("customers/\(customerModel.customerId)", onCompleteHandler: {(response, error) -> Void in
            do {
                guard error == nil else {
                    if (error as NSError?)?.code == 401 {
                        self.performSegue(withIdentifier: "TimeoutSegue", sender: self)
                    }
                    return
                }
                
                guard response != nil else { return }
                
                if let data = response {
                    self.hideWait()
                    self.customerModel = try JSONDecoder().decode(CustomerModel.self, from: data)
                }
                
                DispatchQueue.main.async {
                    self.displayInfo()
                }
            } catch {
                return
            }
        })
    }
        
    func displayInfo() {
        customerName.text = customerModel.customerName
        customerLastname.text = customerModel.customerLastname
        customerPhone.text = customerModel.customerPhone.formatPhoneNumber()
        customerMail.text = customerModel.customerMail
        customerStreet.text = customerModel.customerStreet
        customerColony.text = customerModel.customerColony
        customerCity.text = customerModel.customerCity
        
        if statesList.count > 0 {
            let position = statesList.firstIndex(of: statesList.filter{$0.stateId == customerModel.stateId}.first!)!
            customerStatePickerView.selectRow(position, inComponent: 0, animated: false)
        }
        
        customerZipcode.text = String(customerModel.customerZipcode)
    }
    
    @IBAction func update(_ sender: Any) {
        if !validateInputs() {
            self.alerts.showErrorAlert(self, message: NSLocalizedString("alert_validation_message", tableName: "messages", comment: ""), onComplete: {() -> Void in
                self.setInvalidInputs()
            })
        } else {
            self.showWait()
            
            customerModel.customerName = customerName.text!
            customerModel.customerLastname = customerLastname.text!
            customerModel.customerPhone = customerPhone.unMaskValue()
            customerModel.customerMail = customerMail.text!
            customerModel.customerStreet = customerStreet.text!
            customerModel.customerColony = customerColony.text!
            customerModel.customerCity = customerCity.text!
            customerModel.customerZipcode = customerZipcode.text!
            
            do {
                let data = try JSONEncoder().encode(customerModel)
                
                webApi.DoPost("customers/update", jsonData: data, onCompleteHandler: {(response, error) -> Void in
                    guard error == nil else {
                        if (error as NSError?)?.code == 401 {
                            self.hideWait()
                            self.performSegue(withIdentifier: "TimeoutSegue", sender: self)
                        }
                        return
                    }
                    
                    guard response != nil else { return }
                    
                    do {
                        if let data = response {
                            self.hideWait()
                            self.customerModel = try JSONDecoder().decode(CustomerModel.self, from: data)
                            
                            if self.customerModel.errors.count > 0 {
                                self.alerts.processErrors(self, errors: self.customerModel.errors)
                            }
                            
                            if !self.customerModel.message.isEmpty {
                                self.alerts.showSuccessAlert(self, message: self.customerModel.message, onComplete: {() -> Void in
                                    self.performSegue(withIdentifier: "GoBackSegue", sender: nil)
                                })
                            }
                        }
                    }
                    catch {
                        return
                    }
                })
            } catch {
                
                return
            }
        }
    }
    
    func validateInputs() -> Bool {
        
        guard !customerName.text!.isEmpty else { return false }
        guard !customerLastname.text!.isEmpty else { return false }
        guard !customerPhone.text!.isEmpty else { return false }
        guard !customerStreet.text!.isEmpty else { return false }
        guard !customerColony.text!.isEmpty else { return false }
        guard !customerCity.text!.isEmpty else { return false }
        guard !customerZipcode.text!.isEmpty else { return false }
        
        return true
    }
    
    func setInvalidInputs() {
        if customerName.text!.isEmpty {
            customerName.setValidationError()
        } else  {
            customerName.clearValidationError()
        }
        
        if customerLastname.text!.isEmpty {
            customerLastname.setValidationError()
        } else {
            customerLastname.clearValidationError()
        }
        
        if customerPhone.text!.isEmpty {
            customerPhone.setValidationError()
        } else  {
            customerPhone.clearValidationError()
        }
        
        if customerStreet.text!.isEmpty {
            customerStreet.setValidationError()
        } else {
            customerStreet.clearValidationError()
        }
        
        if customerColony.text!.isEmpty {
            customerColony.setValidationError()
        } else {
            customerColony.clearValidationError()
        }
        
        if customerCity.text!.isEmpty {
            customerCity.setValidationError()
        } else {
            customerCity.clearValidationError()
        }
        
        if customerZipcode.text!.isEmpty {
            customerZipcode.setValidationError()
        } else {
            customerZipcode.clearValidationError()
        }
        
        if customerModel.stateId <= 0 {
            statePickerBorder.backgroundColor = UIColor.red
        } else {
            statePickerBorder.backgroundColor = UIColor.lightGray
        }
    }
    
}
