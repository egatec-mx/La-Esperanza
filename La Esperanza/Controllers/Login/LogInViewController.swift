//
//  LogInController.swift
//  La Esperanza
//
//  Created by Efrain Garcia Rocha on 01/07/20.
//  Copyright © 2020 Efrain Garcia Rocha. All rights reserved.
//

import UIKit
import LocalAuthentication

class LogInViewController: UIViewController, UITextFieldDelegate {
    let authenticationContext = LAContext()
    let webApi: WebApi = WebApi()
    var isKeyboardAppear: Bool = false
    var loginModel: LoginModel = LoginModel()
    var savedCredentials: Bool = false
    var useFaceID: Bool = true
    
    @IBOutlet var VerticalStackLogIn: UIStackView!
    @IBOutlet var TextFieldUsername: UITextField!
    @IBOutlet var TextFieldPassword: UITextField!
    @IBOutlet var ButtonContinue: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        savedCredentials = UserDefaults.standard.bool(forKey: "SavedCredentials")
        
        if savedCredentials && useFaceID {
            logInWithCredentials()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @IBAction func hideKeyboard(_ sender: Any) {
        view.endEditing(true)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if !isKeyboardAppear {
            if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                if view.frame.origin.y == 0 {
                    view.frame.origin.y -= keyboardSize.height / 2
                }
            }
            isKeyboardAppear = true
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if isKeyboardAppear {
            if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                if view.frame.origin.y != 0 {
                    view.frame.origin.y += keyboardSize.height / 2
                }
            }
             isKeyboardAppear = false
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == TextFieldUsername {
            TextFieldPassword.becomeFirstResponder()
        } else {
            TextFieldPassword.resignFirstResponder()
            ButtonContinueClick(textField)
        }
        
        return true
    }
    
    @IBAction func ButtonContinueClick(_ sender: Any) {
        loginModel.userName = TextFieldUsername.text ?? ""
        loginModel.password = TextFieldPassword.text ?? ""
        
        doLogIn()
    }
    
    func showErrorAlert(_ message: String, onCompleteHandler: (() -> Void)?) {
        let alert = UIAlertController(title: NSLocalizedString("error_title", tableName: "messages", comment: ""), message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("alert_accept", tableName: "messages", comment: ""), style: .default, handler: { (action) -> Void in
            onCompleteHandler?()
        }))
        present(alert, animated: true, completion: nil)
    }
    
    func logInWithCredentials() {
        loginModel.userName = UserDefaults.standard.string(forKey: "UserName")!
        loginModel.password = UserDefaults.standard.string(forKey: "UserPassword")!
        
        doLogIn()
    }
    
    func doLogIn() {
        do {
            let data = try JSONEncoder().encode(loginModel)
            
            webApi.DoPost("account/login", jsonData: data, onCompleteHandler: { (response, error) -> Void in
                
                guard error == nil else {
                    self.showErrorAlert(NSLocalizedString("error_not_connection", tableName: "messages", comment: ""), onCompleteHandler: nil)
                    return
                }
                
                guard response != nil else {
                    self.showErrorAlert(NSLocalizedString("error_not_response", tableName: "messages", comment: ""), onCompleteHandler: nil)
                    return
                }
                
                do {
                    if let data = response {
                        self.loginModel = try JSONDecoder().decode(LoginModel.self, from: data)
                        
                        if self.loginModel.errors.count > 0 {
                            var message: String = ""
                            var i: Int = 0
                            
                            for error in self.loginModel.errors {
                                if i > 0 { message += "\n\r" }
                                message += "\(error)"
                                i += 1
                            }
                            
                            self.showErrorAlert(message, onCompleteHandler: nil)
                        }
                        
                        if !self.loginModel.token.isEmpty {
                            
                            UserDefaults.standard.set(self.loginModel.token, forKey: "JWTToken")
                            UserDefaults.standard.synchronize()
                            
                            if !self.savedCredentials {
                                self.loginModel.password = self.TextFieldPassword.text!
                            }
                            
                            if self.useFaceID {
                                self.useBiometrics()
                            } else {
                                self.navigateToNextView("MainViewController")
                            }
                        }
                    }
                } catch {
                    return
                }
            })
        } catch {
            return
        }
    }
    
    func useBiometrics() {
        var authError: NSError?
        
        if self.authenticationContext.canEvaluatePolicy(.deviceOwnerAuthentication, error: &authError) {
            self.authenticationContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: NSLocalizedString("auth_reason", tableName: "messages", comment: "")) { (succes, error) in
                
                if succes {
                                        
                    if !self.savedCredentials {
                        UserDefaults.standard.set(self.loginModel.userName, forKey: "UserName")
                        UserDefaults.standard.set(self.loginModel.password, forKey: "UserPassword")
                        UserDefaults.standard.set(true, forKey: "SavedCredentials")
                        UserDefaults.standard.synchronize()
                    }
                    
                    self.navigateToNextView("MainViewController")
                    
                } else {
                    var message: String = ""
                    var canContinue: Bool = false;
                    self.useFaceID = false
                    
                    switch error {
                        case LAError.authenticationFailed?:
                          message = NSLocalizedString("error_auth_failed", tableName: "messages", comment: "")
                        case LAError.userCancel?:
                          message = NSLocalizedString("error_auth_cancel", tableName: "messages", comment: "")
                        case LAError.userFallback?:
                          message = NSLocalizedString("error_auth_fallback", tableName: "messages", comment: "")
                        case LAError.biometryNotAvailable?:
                          message = NSLocalizedString("error_auth_biometric_not_available", tableName: "messages", comment: "")
                          canContinue = true
                        case LAError.biometryNotEnrolled?:
                          message = NSLocalizedString("error_auth_not_enrolled", tableName: "messages", comment: "")
                          canContinue = true
                        case LAError.biometryLockout?:
                          message = NSLocalizedString("error_auth_biometric_locked", tableName: "messages", comment: "")
                        default:
                          message = NSLocalizedString("error_auth_default", tableName: "messages", comment: "")
                    }
                    
                    if canContinue {
                        DispatchQueue.main.async {
                            self.showErrorAlert(message, onCompleteHandler: {() -> Void in
                                self.navigateToNextView("MainViewController")
                            })
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.showErrorAlert(message, onCompleteHandler: nil)
                        }
                    }
                }
            }
        }
    }
    
    func navigateToNextView(_ viewId: String) {
        DispatchQueue.main.async {
            if self.view.frame.origin.y != 0 {
                self.view.frame.origin.y = 0
            }
            let next = (self.storyboard?.instantiateViewController(identifier: viewId))!
            next.modalPresentationStyle = .currentContext
            self.present(next, animated: true, completion: nil)
        }
    }
}
