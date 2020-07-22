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
        
        if !delay {
            DispatchQueue.main.async {
                controller.present(successAlert, animated: true, completion: nil)
            }
        } else  {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: { () -> Void in
                controller.present(successAlert, animated: true, completion: nil)
            })
        }
    }
    
    func showErrorAlert(_ controller: UIViewController, message: String, delay: Bool = true, onComplete: (() -> Void)?) {
        let errorAlert = UIAlertController(title: NSLocalizedString("error_title", tableName: "messages", comment: ""), message: message, preferredStyle: .alert)
        
        errorAlert.addAction(UIAlertAction(title: NSLocalizedString("alert_accept", tableName: "messages", comment: ""), style: .default, handler: { (action) -> Void in
            
            onComplete?()
        }))
        
        if !delay {
            DispatchQueue.main.async {
                controller.present(errorAlert, animated: true, completion: nil)
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: { () -> Void in
                controller.present(errorAlert, animated: true, completion: nil)
            })
        }
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
}
