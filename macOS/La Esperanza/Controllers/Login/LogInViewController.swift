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
    let appDefaults: UserDefaults = UserDefaults(suiteName: (UIApplication.shared.delegate as! AppDelegate).suiteName)!
    let authenticationContext = LAContext()
    let webApi: WebApi = WebApi()
    let alerts: AlertsHelper = AlertsHelper()
    var isKeyboardAppear: Bool = false
    var loginModel: LoginModel = LoginModel()
    var savedCredentials: Bool = false
    var useFaceID: Bool = true
    
    @IBOutlet var VerticalStackLogIn: UIStackView!
    @IBOutlet var TextFieldUsername: ImageTextField!
    @IBOutlet var TextFieldPassword: ImageTextField!
    @IBOutlet var ButtonContinue: RoundedUIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
                        
        savedCredentials = appDefaults.bool(forKey: "SavedCredentials")
        
        if savedCredentials && useFaceID {
            logInWithCredentials()
        }        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
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
        
        if loginModel.userName.isEmpty || loginModel.password.isEmpty {
            alerts.showErrorAlert(self, message: NSLocalizedString("alert_validation_message", tableName: "messages", comment: ""), onComplete: {
                
                if self.loginModel.userName.isEmpty {
                    self.TextFieldUsername.setValidationError()
                }
                
                if self.loginModel.password.isEmpty {
                    self.TextFieldPassword.setValidationError()
                }
            })
        } else {
            doLogIn()
        }
    }
    
    func logInWithCredentials() {
        loginModel.userName = appDefaults.string(forKey: "UserName")!
        loginModel.password = appDefaults.string(forKey: "UserPassword")!
        
        doLogIn()
    }
    
    func doLogIn() {
        self.showWait { [self] in
            do {
                let data = try JSONEncoder().encode(loginModel)
                webApi.DoPost("account/login", jsonData: data, onCompleteHandler: { response, error in
                    guard error == nil else {
                        if (error as NSError?)?.code != 401 {
                            hideWait {
                                self.alerts.showErrorAlert(self, message: NSLocalizedString("error_not_connection", tableName: "messages", comment: ""), onComplete: nil)
                            }
                        }
                        return
                    }
                    
                    guard response != nil else { return }
                    
                    do {
                        if let data = response {
                            loginModel = try JSONDecoder().decode(LoginModel.self, from: data)
                        }
                    } catch {
                        hideWait {
                            return
                        }
                    }
                    
                    hideWait {
                        if loginModel.errors.count > 0 {
                            alerts.processErrors(self, errors: loginModel.errors)
                        }
                        
                        if !loginModel.token.isEmpty {
                            appDefaults.set(loginModel.token, forKey: "JWTToken")
                            appDefaults.synchronize()
                                                        
                            if !self.savedCredentials {
                                self.loginModel.password = TextFieldPassword.text!
                            }
                            
                            if self.useFaceID {
                                self.useBiometrics()
                            } else {
                                self.registerDevice()
                            }
                        }
                    }
                })
            } catch {
                hideWait {
                    return
                }
            }
        }
    }
    
    func useBiometrics() {
        var authError: NSError?
        
        if self.authenticationContext.canEvaluatePolicy(.deviceOwnerAuthentication, error: &authError) {
            self.authenticationContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: NSLocalizedString("auth_reason", tableName: "messages", comment: "")) { [self] succes, error in
                
                if succes {
                    if !savedCredentials {
                        appDefaults.set(loginModel.userName, forKey: "UserName")
                        appDefaults.set(loginModel.password, forKey: "UserPassword")
                        appDefaults.set(true, forKey: "SavedCredentials")
                        appDefaults.synchronize()
                    }
                    
                    registerDevice()
                    
                } else {
                    var message: String = ""
                    var canContinue: Bool = false;
                    useFaceID = false
                    
                    appDefaults.set("", forKey: "UserName")
                    appDefaults.set("", forKey: "UserPassword")
                    appDefaults.set(false, forKey: "SavedCredentials")
                    appDefaults.synchronize()
                    
                    switch error {
                        case LAError.authenticationFailed?:
                          message = NSLocalizedString("error_auth_failed", tableName: "messages", comment: "")
                        case LAError.userCancel?:
                          message = NSLocalizedString("error_auth_cancel", tableName: "messages", comment: "")
                        case LAError.userFallback?:
                          message = NSLocalizedString("error_auth_fallback", tableName: "messages", comment: "")
                        case LAError.biometryNotAvailable?:
                          message = NSLocalizedString("error_auth_biometric_not_available", tableName: "messages", comment: "")
                          canContinue = !savedCredentials
                        case LAError.biometryNotEnrolled?:
                          message = NSLocalizedString("error_auth_not_enrolled", tableName: "messages", comment: "")
                          canContinue = !savedCredentials
                        case LAError.biometryLockout?:
                          message = NSLocalizedString("error_auth_biometric_locked", tableName: "messages", comment: "")
                        default:
                          message = NSLocalizedString("error_auth_default", tableName: "messages", comment: "")
                    }
                    
                    if canContinue {
                        alerts.showErrorAlert(self, message: message, onComplete: {
                            registerDevice()
                        })
                    } else {
                        alerts.showErrorAlert(self, message: message, onComplete: nil)
                    }
                }
            }
        }
    }
    
    func registerDevice() {
        var device: DeviceModel = DeviceModel()
        
        if let token = UserDefaults.standard.string(forKey: "PushToken") {
            device.devicePushP256dh = token
            
            do{
                let data = try JSONEncoder().encode(device)
                webApi.DoPost("account/register", jsonData: data, onCompleteHandler: {_ , _ in
                    self.navigateToNextView()
                })
            } catch {
                return
            }
        } else {
            self.navigateToNextView()
        }
    }
    
    func navigateToNextView() {
        DispatchQueue.main.async {
            if self.view.frame.origin.y != 0 { self.view.frame.origin.y = 0 }
            self.performSegue(withIdentifier: "MainViewSegue", sender: self)
        }
    }
    
    @IBAction func sessionExpired(_ segue: UIStoryboardSegue) {
        self.alerts.showErrorAlert(self, message: NSLocalizedString("alert_session_timeout", tableName: "messages", comment: ""), onComplete: { [self] in
            
            appDefaults.set("", forKey: "JWTToken")
            appDefaults.synchronize()
            
            TextFieldPassword.text = ""
            TextFieldUsername.text = ""
            logInWithCredentials()
        })
    }
}
