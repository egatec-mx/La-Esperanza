//
//  AlertsHelper.swift
//  La Esperanza
//
//  Created by Efrain Garcia Rocha on 19/07/20.
//  Copyright © 2020 Efrain Garcia Rocha. All rights reserved.
//

import UIKit

class AlertsHelper {
    func showSuccessAlert(_ controller: UIViewController, message: String, delay: Bool = true, onComplete: (() -> Void)?) {
        let successAlert = UIAlertController(title: NSLocalizedString("alert_success", tableName: "messages", comment: ""), message: message, preferredStyle: .alert)
        
        successAlert.addAction(UIAlertAction(title: NSLocalizedString("alert_accept", tableName: "messages", comment: ""), style: .default, handler: { (action) -> Void in
            
            onComplete?()
        }))
        
        DispatchQueue.main.asyncAfter(deadline: .now() + (delay ? 1.5 : 0), execute: { () -> Void in
            controller.present(successAlert, animated: true, completion: nil)
        })
    }
    
    func showErrorAlert(_ controller: UIViewController, message: String, delay: Bool = true, onComplete: (() -> Void)?) {
        let errorAlert = UIAlertController(title: NSLocalizedString("error_title", tableName: "messages", comment: ""), message: message, preferredStyle: .alert)
        
        errorAlert.addAction(UIAlertAction(title: NSLocalizedString("alert_accept", tableName: "messages", comment: ""), style: .default, handler: { (action) -> Void in
            
            onComplete?()
        }))
        
        DispatchQueue.main.asyncAfter(deadline: .now() + (delay ? 1.5 : 0), execute: { () -> Void in
            controller.present(errorAlert, animated: true, completion: nil)
        })
    }
    
    func processErrors(_ controller: UIViewController, errors: [String]) {
        if errors.count > 0 {
            var message: String = ""
            var i: Int = 0
            
            for error in errors {
                if i > 0 { message += "\n\r" }
                message += "\(error)"
                i += 1
            }
            
            showErrorAlert(controller, message: message, onComplete: nil)
        }
    }
    
    func showMapsOptions(_ controller: UIViewController, customer: CustomerModel, delay: Bool = false) {
        let mapsAlert = UIAlertController(title: NSLocalizedString("alert_navigation_title", tableName: "messages", comment: ""), message: NSLocalizedString("alert_navigation_message", tableName: "messages", comment: ""), preferredStyle: .actionSheet)
        
        let mapsAction = UIAlertAction(title: "Apple Maps", style: .default, handler: {(action) -> Void in
            let address = "\(customer.customerStreet.replacingOccurrences(of: " ", with: "+")),\(customer.customerColony.replacingOccurrences(of: " ", with: "+")),\(customer.customerCity.replacingOccurrences(of: " ", with: "+")),\(customer.stateName.replacingOccurrences(of: " ", with: "+")),\(customer.customerZipcode),\(customer.countryName)".folding(options: .diacriticInsensitive, locale: .current)
            
            if let mapsURL = URL(string: "https://maps.apple.com/?address=\(address)") {
                UIApplication.shared.open(mapsURL, options: [:], completionHandler: nil)
            }
        })
        
        let wazeAction = UIAlertAction(title: "Waze", style: .default, handler: {(action) -> Void in
            let address = "\(customer.customerStreet.replacingOccurrences(of: " ", with: "%20")),\(customer.customerColony.replacingOccurrences(of: " ", with: "%20")),\(customer.customerCity.replacingOccurrences(of: " ", with: "%20")),\(customer.stateName.replacingOccurrences(of: " ", with: "%20")),\(customer.customerZipcode),\(customer.countryName)".folding(options: .diacriticInsensitive, locale: .current)
            
            if let mapsURL = URL(string: "https://waze.com/ul?q=\(address)&navigate=yes") {
                UIApplication.shared.open(mapsURL, options: [:], completionHandler: nil)
            }
        })
        
        let googleMapsAction = UIAlertAction(title: "Google Maps", style: .default, handler: {(action) -> Void in
            let address = "\(customer.customerStreet.replacingOccurrences(of: " ", with: "+")),\(customer.customerColony.replacingOccurrences(of: " ", with: "+")),\(customer.customerCity.replacingOccurrences(of: " ", with: "+")),\(customer.stateName.replacingOccurrences(of: " ", with: "+")),\(customer.customerZipcode),\(customer.countryName)".folding(options: .diacriticInsensitive, locale: .current)
            if let googleUrl = URL(string: "comgooglemaps://?q=\(address)") {
                UIApplication.shared.open(googleUrl, options: [:], completionHandler: nil)
            }
        })
        
        let dismissAction = UIAlertAction(title: NSLocalizedString("alert_navigation_dismiss", tableName: "messages", comment: ""), style: .cancel, handler: nil)
        
        mapsAlert.addAction(wazeAction)
        mapsAlert.addAction(googleMapsAction)
        mapsAlert.addAction(mapsAction)
        mapsAlert.addAction(dismissAction)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + (delay ? 1.5 : 0), execute: {() -> Void in
            controller.present(mapsAlert, animated: true, completion: nil)
        })
    }
    
    func showPhoneOptions(_ controller: UIViewController, customer: CustomerModel, delay: Bool = false) {        
        let phoneAlert = UIAlertController(title: NSLocalizedString("alert_phone_title", tableName: "messages", comment: ""), message: NSLocalizedString("alert_phone_message", tableName: "messages", comment: ""), preferredStyle: .actionSheet)
        
        let callAction = UIAlertAction(title: NSLocalizedString("menu_call", tableName: "messages", comment: ""), style: .default, handler: {(action) -> Void in
            let url:URL = URL(string: "tel://\(customer.customerPhone)")!
            UIApplication.shared.open(url as URL)
        })
                
        let whatsAppAction = UIAlertAction(title: NSLocalizedString("menu_message", tableName: "messages", comment: ""), style: .default, handler: {(action) -> Void in
            let url:URL = URL(string: "whatsapp://send?phone=+521\(customer.customerPhone)&abid=+521\(customer.customerPhone)")!
            UIApplication.shared.open(url as URL)
        })
        
        let dismissAction = UIAlertAction(title: NSLocalizedString("alert_phone_dismiss", tableName: "messages", comment: ""), style: .cancel, handler: nil)
        
        phoneAlert.addAction(callAction)
        phoneAlert.addAction(whatsAppAction)
        phoneAlert.addAction(dismissAction)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + (delay ? 1.5 : 0), execute: {() -> Void in
            controller.present(phoneAlert, animated: true, completion: nil)
        })
    }
}
