//
//  NewCustomerTableViewController.swift
//  La Esperanza
//
//  Created by Efrain Garcia Rocha on 18/07/20.
//  Copyright © 2020 Efrain Garcia Rocha. All rights reserved.
//

import UIKit

class NewCustomerTableViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    let webApi: WebApi = WebApi()
    let alerts: AlertsHelper = AlertsHelper()
    var customerModel: CustomerModel = CustomerModel()
    var statesList: [StatesList] = []
    var sourceSegue: String = ""
    
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
                        self.hideWait()
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
                }
            } catch {
                return
            }
        })
    }
    
    @IBAction func save(_ sender: Any) {
        if !validateInputs() {
            self.alerts.showErrorAlert(self, message: NSLocalizedString("alert_validation_message", tableName: "messages", comment: ""), delay: false, onComplete: {() -> Void in
                self.setInvalidInputs()
            })            
        } else {
            
            self.showWait({ [self]() -> Void in
                customerModel.customerId = 0
                customerModel.customerActive = true
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
                
                    webApi.DoPost("customers/add", jsonData: data, onCompleteHandler: {(response, error) -> Void in
                                            
                        guard error == nil else {
                            if (error as NSError?)?.code == 401 {
                                hideWait()
                                performSegue(withIdentifier: "TimeoutSegue", sender: self)
                            }
                            return
                        }
                        
                        guard response != nil else { return }
                        
                        do {
                            if let data = response {
                                hideWait()
                                
                                customerModel = try JSONDecoder().decode(CustomerModel.self, from: data)
                                
                                if customerModel.errors.count > 0 {
                                    alerts.processErrors(self, errors: customerModel.errors)
                                }
                                
                                if !customerModel.message.isEmpty {
                                    alerts.showSuccessAlert(self, message: customerModel.message, onComplete: {() -> Void in
                                        if sourceSegue == "NewSegue" {
                                            performSegue(withIdentifier: "ReloadSegue", sender: nil)
                                        } else {
                                            performSegue(withIdentifier: "GoBackSegue", sender: nil)
                                        }
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
            })
                        
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
