//
//  OrderDetailsController.swift
//  La Esperanza
//
//  Created by Efrain Garcia Rocha on 03/07/20.
//  Copyright © 2020 Efrain Garcia Rocha. All rights reserved.
//

import UIKit

class OrderDetailsController: UITableViewController {
    let webApi: WebApi = WebApi()
    let alerts: AlertsHelper = AlertsHelper()
    let numberFormatter: NumberFormatter = NumberFormatter()
    let dateFormatter: DateFormatter = DateFormatter()
    var orderId: CLongLong = 0
    var orderDetails: OrderDetailsModel = OrderDetailsModel()
    var moveOrderModel: MoveOrderModel = MoveOrderModel()
    var cancelOrderModel: CancelOrderModel = CancelOrderModel()
    var rejectOrderModel: RejectOrderModel = RejectOrderModel()
    var reasonTextField: UITextField!
        
    @IBOutlet var ImageQrCode: UIImageView!
    @IBOutlet var LabelOrder: UILabel!
    @IBOutlet var LabelCreationDate: UILabel!
    @IBOutlet var LabelCreationTime: UILabel!
    @IBOutlet var LabelPaymentMethod: UILabel!
    @IBOutlet var LabelDeliverDate: UILabel!
    @IBOutlet var LabelDeliverTime: UILabel!
    @IBOutlet var LabelCustomerName: UILabel!
    @IBOutlet var LabelAddress: UILabel!
    @IBOutlet var ArticlesTable: ArticlesTableView!
    @IBOutlet var LabelNotes: UILabel!
    @IBOutlet var LabelDeliveryTax: UILabel!
    @IBOutlet var LabelOrderTotal: UILabel!
    @IBOutlet var ScrollView: UIScrollView!
    @IBOutlet var MoveButton: UIBarButtonItem!
    @IBOutlet var DeleteButton: UIBarButtonItem!
    @IBOutlet var EditButton: UIBarButtonItem!
    @IBOutlet var IconStatus: UIImageView!
    @IBOutlet var RejectButton: UIBarButtonItem!
    @IBOutlet var CustomerPhoneButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        clearDataFromUI()
               
        dateFormatter.locale = Locale(identifier: UserDefaults.standard.string(forKey: "DEFAULT_LOCALE")!)
        dateFormatter.calendar = Calendar.current
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                    
        ArticlesTable.delegate = ArticlesTable.self
        ArticlesTable.dataSource = ArticlesTable.self
        
        getDetails()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setToolbarHidden(false, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 && indexPath.row == 0 {
            if orderDetails.orderQrCode == nil {
                return 0
            }
        } else if indexPath.section == 2 {
            return CGFloat(Double(orderDetails.articles.count) * 42.5)
        } else if indexPath.section == 4 {
            return (LabelNotes.frame.height * 0.85 < 150 ? 150 : LabelNotes.frame.height * 0.85)
        }
        
        return super.tableView(tableView, heightForRowAt: indexPath)
    }
    
    func displayInfo() {
        tableView.beginUpdates()
        
        //Qr Code
        if orderDetails.orderQrCode != nil {
            if let qrData: Data = Data(base64Encoded: orderDetails.orderQrCode!) {
                if let qrCode: UIImage = UIImage(data: qrData) {
                    ImageQrCode.image = qrCode
                }
            }
        } else {
            ImageQrCode.isHidden = true
        }
        
        //Label Order Id
        LabelOrder.text = String(orderDetails.orderId).leftPadding(toLength: 6, withPad: "0")
        
        if let index = orderDetails.orderDate.lastIndex(of: ".") {
            let oIdx = orderDetails.orderDate.index(index, offsetBy: -1)
            orderDetails.orderDate = String(orderDetails.orderDate[...oIdx])
        }
        
        //Label Create Date
        if let cDate: Date = dateFormatter.date(from: orderDetails.orderDate) {
            let printDate: DateFormatter = DateFormatter()
            printDate.setLocalizedDateFormatFromTemplate("dd/MM/YYYY")
            LabelCreationDate.text = printDate.string(for: cDate)
        }
        
        //Label Create Time
        if let cTime: Date = dateFormatter.date(from: orderDetails.orderDate) {
            let printTime: DateFormatter = DateFormatter()
            printTime.timeStyle = .short
            printTime.timeZone = TimeZone.current
            printTime.setLocalizedDateFormatFromTemplate("hh:mm a")
            
            LabelCreationTime.text = printTime.string(for: cTime)
        }
        
        //Label Delivery Date
        if orderDetails.orderScheduleDate != nil {
            if let dDate: Date = dateFormatter.date(from: orderDetails.orderScheduleDate!) {
               let printDate: DateFormatter = DateFormatter()
               printDate.setLocalizedDateFormatFromTemplate("dd/MM/YYYY")
               LabelDeliverDate.text = printDate.string(for: dDate)
            }
        } else {
            LabelDeliverDate.text = "N/A"
        }
       
        //Label Delivery Time
        if orderDetails.orderScheduleDate != nil {
            if let dTime: Date = dateFormatter.date(from: orderDetails.orderScheduleDate!) {
                let printTime: DateFormatter = DateFormatter()
                printTime.timeStyle = .short
                printTime.timeZone = TimeZone.current
                printTime.setLocalizedDateFormatFromTemplate("hh:mm a")
               
                LabelDeliverTime.text = printTime.string(for: dTime)
            }
        } else {
            LabelDeliverTime.text = "N/A"
        }
        
        //Label Method of Payment
        LabelPaymentMethod.text = orderDetails.paymentMethod
        
        //Label Customer Name
        LabelCustomerName.text = "\(orderDetails.customerName) \(orderDetails.customerLastname)"
        
        //Label Customer Phone
        CustomerPhoneButton.setTitle(orderDetails.customerPhone.formatPhoneNumber(), for: .normal)
        
        //Label Address
        LabelAddress.text = """
                            \(orderDetails.customerStreet),
                            \(orderDetails.customerColony),
                            \(orderDetails.customerCity),
                            \(orderDetails.stateName), C.P \(orderDetails.customerZipcode),                            
                            \(orderDetails.countryName)
                            """
        LabelAddress.frame.size = CGSize(width: LabelAddress.frame.width, height: LabelAddress.height(text: LabelAddress.text!, font: LabelAddress.font, width: LabelAddress.frame.width))
        
        //Articles
        ArticlesTable.articles = orderDetails.articles
        ArticlesTable.reloadData()
        
        //Label Totals
        numberFormatter.numberStyle = .currency
        numberFormatter.locale = Locale(identifier: UserDefaults.standard.string(forKey: "DEFAULT_LOCALE")!)
        
        if orderDetails.orderDeliveryTax != nil {
            LabelDeliveryTax.text = numberFormatter.string(for: orderDetails.orderDeliveryTax)
        } else {
            LabelDeliveryTax.text = "N/A"
        }
        
        LabelOrderTotal.text = numberFormatter.string(for: orderDetails.orderTotal)
        
        //Label Notes
        if orderDetails.orderNotes != nil {
            LabelNotes.text = orderDetails.orderNotes
            LabelNotes.frame.size = CGSize(width: LabelNotes.frame.width, height: LabelNotes.height(text: orderDetails.orderNotes!, font: LabelNotes.font, width: LabelNotes.frame.width))
        
            //Update Scroll View
            ScrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: (LabelNotes.frame.height * 1.15), right: 0)
        }
        
        if (orderDetails.statusId == 1 || orderDetails.statusId == 2) && toolbarItems!.count > 5 {
            toolbarItems?.remove(at: 1)
            toolbarItems?.remove(at: 1)
        } else if orderDetails.statusId >= 4 {
            MoveButton.isEnabled = false
            DeleteButton.isEnabled = false
            EditButton.isEnabled = false
            RejectButton.isEnabled = false
        }
        
        switch orderDetails.statusId {
        case 1:
            IconStatus.image = UIImage(systemName: "bell")
            IconStatus.tintColor = UIColor.systemTeal
        case 2:
            IconStatus.image = UIImage(systemName: "clock")
            IconStatus.tintColor = UIColor.systemOrange
        case 3:
            IconStatus.image = UIImage(systemName: "car")
            IconStatus.tintColor = UIColor.systemPurple
        case 4:
            IconStatus.image = UIImage(systemName: "hand.thumbsup")
            IconStatus.tintColor = UIColor.systemGreen
        case 5:
            IconStatus.image = UIImage(systemName: "trash.slash")
            IconStatus.tintColor = UIColor.systemRed
        case 6:
            IconStatus.image = UIImage(systemName: "hand.thumbsdown")
            IconStatus.tintColor = UIColor.systemPink
        default:
            IconStatus.image = UIImage(systemName: "bell")
            IconStatus.tintColor = UIColor.systemTeal
        }
        
        tableView.endUpdates()
        
    }
       
    func clearDataFromUI() {
        ImageQrCode.image = nil
                 
        //Label Order Id
        LabelOrder.text = ""
        
        //Label Create Date
        LabelCreationDate.text = ""
         
        //Label Create Time
        LabelCreationTime.text = ""
         
        //Label Delivery Date
        LabelDeliverDate.text = ""
         
        //Label Delivery Time
        LabelDeliverTime.text = ""
         
        //Label Method of Payment
        LabelPaymentMethod.text = ""
         
        //Label Customer Name
        LabelCustomerName.text = ""
        
        //Customer Phone
        CustomerPhoneButton.titleLabel?.text = ""
        
        //Label Address
        LabelAddress.text = ""
         
        //Label Totals
        LabelDeliveryTax.text = ""
        LabelOrderTotal.text = ""
         
        //Label Notes
        LabelNotes.text = ""
        
        //Icon Status
        IconStatus.image = UIImage(systemName: "bell")
        IconStatus.tintColor = UIColor.systemTeal
    }
    
    func configurationTextField(_ textField: UITextField) {
        self.reasonTextField = textField
        if orderDetails.statusId == 3 {
            textField.placeholder = NSLocalizedString("alert_reject_reason", tableName: "messages", comment: "")
        } else {
            textField.placeholder = NSLocalizedString("alert_delete_reason", tableName: "messages", comment: "")
        }
    }
    
    @IBAction func moveOrder(_ sender: Any) {
        self.showWait{ [self] in
            do {
                moveOrderModel.orderId = orderId
                            
                let data = try JSONEncoder().encode(moveOrderModel)
                webApi.DoPost("orders/advance", jsonData: data, onCompleteHandler: { response, error in
                    guard error == nil else {
                        if (error as NSError?)?.code == 401 {
                            hideWait {
                                performSegue(withIdentifier: "TimeoutSegue", sender: self)
                            }
                        }
                        return
                    }
                    
                    guard response != nil else { return }
                    
                    do {
                        if let data = response {
                            moveOrderModel = try JSONDecoder().decode(MoveOrderModel.self, from: data)
                        }
                    } catch {
                        hideWait {
                            print(error)
                            return
                        }
                    }
                    
                    hideWait {
                        if moveOrderModel.errors.count > 0 {
                            alerts.processErrors(self, errors: moveOrderModel.errors)
                        }
                        
                        if !moveOrderModel.message.isEmpty {
                            alerts.showSuccessAlert(self, message: moveOrderModel.message, onComplete: {
                                performSegue(withIdentifier: "GoBackSegue", sender: self)
                            })
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
    
    @IBAction func cancelOrder(_ sender: Any) {
        
        let deleteAlert = UIAlertController(title: NSLocalizedString("alert_delete_title", tableName: "messages", comment: ""), message: NSLocalizedString("alert_delete_message", tableName: "messages", comment: ""), preferredStyle: .alert)
        
        deleteAlert.addTextField(configurationHandler: self.configurationTextField)
        
        deleteAlert.addAction(UIAlertAction(title: NSLocalizedString("alert_delete_cancel", tableName: "messages", comment: ""), style: .destructive, handler: nil))
        
        deleteAlert.addAction(UIAlertAction(title: NSLocalizedString("alert_delete_accept", tableName: "messages", comment: ""), style: .default, handler: { action in
            
            self.cancelOrderModel.orderId = self.orderId
            self.cancelOrderModel.cancelReason = self.reasonTextField.text!
            
            self.showWait { [self] in
                do {
                    let data = try JSONEncoder().encode(cancelOrderModel)
                    webApi.DoPost("orders/cancel", jsonData: data, onCompleteHandler: { response, error in
                        guard error == nil else {
                            if (error as NSError?)?.code == 401 {
                                hideWait {
                                    performSegue(withIdentifier: "TimeoutSegue", sender: self)
                                }
                            }
                            return
                        }
                        
                        guard response != nil else { return }
                        
                        do {
                            if let data = response {
                                cancelOrderModel = try JSONDecoder().decode(CancelOrderModel.self, from: data)
                            }
                        } catch {
                            hideWait {
                                print(error)
                                return
                            }
                        }
                        
                        hideWait {
                            if cancelOrderModel.errors.count > 0 {
                                alerts.processErrors(self, errors: self.cancelOrderModel.errors)
                            }
                            
                            if !cancelOrderModel.message.isEmpty {
                                alerts.showSuccessAlert(self, message: cancelOrderModel.message, onComplete: {
                                    performSegue(withIdentifier: "GoBackSegue", sender: self)
                                })
                            }
                        }
                    })
                } catch {
                    hideWait {
                        return
                    }
                }
            }
        }))
        
        self.present(deleteAlert, animated: true, completion: nil)
        
    }
    
    @IBAction func rejectOrder(_ sender: Any) {
        
        let rejectAlert = UIAlertController(title: NSLocalizedString("alert_reject_title", tableName: "messages", comment: ""), message: NSLocalizedString("alert_reject_message", tableName: "messages", comment: ""), preferredStyle: .alert)
        
        rejectAlert.addTextField(configurationHandler: self.configurationTextField)
        
        rejectAlert.addAction(UIAlertAction(title: NSLocalizedString("alert_delete_cancel", tableName: "messages", comment: ""), style: .destructive, handler: nil))
        
        rejectAlert.addAction(UIAlertAction(title: NSLocalizedString("alert_delete_accept", tableName: "messages", comment: ""), style: .default, handler: { action in
            
            self.rejectOrderModel.orderId = self.orderId
            self.rejectOrderModel.rejectReason = self.reasonTextField.text!
            
            self.showWait { [self] in
                do {
                    let data = try JSONEncoder().encode(rejectOrderModel)
                    webApi.DoPost("orders/reject", jsonData: data, onCompleteHandler: { response, error in
                        guard error == nil else {
                            if (error as NSError?)?.code == 401 {
                                hideWait {
                                    performSegue(withIdentifier: "TimeoutSegue", sender: self)
                                }
                            }
                            return
                        }
                        
                        guard response != nil else { return }
                        
                        do {
                            if let data = response {
                                self.rejectOrderModel = try JSONDecoder().decode(RejectOrderModel.self, from: data)
                            }
                        } catch {
                            hideWait {
                                print(error)
                                return
                            }
                        }
                        
                        hideWait {
                            if rejectOrderModel.errors.count > 0 {
                                alerts.processErrors(self, errors: rejectOrderModel.errors)
                            }
                            
                            if !rejectOrderModel.message.isEmpty {
                                alerts.showSuccessAlert(self, message: rejectOrderModel.message, onComplete: {
                                    performSegue(withIdentifier: "GoBackSegue", sender: self)
                                })
                            }
                        }
                    })
                } catch {
                    hideWait {
                        return
                    }
                }
            }
        }))
        
        self.present(rejectAlert, animated: true, completion: nil)
    }
    
    
    func getDetails() {
        webApi.DoGet("orders/\(orderId)", onCompleteHandler: { response, error in
            guard error == nil else {
                if (error as NSError?)?.code == 401 {
                    self.performSegue(withIdentifier: "TimeoutSegue", sender: self)
                }
                return
            }
            
            guard response != nil else { return }
            
            do {
                if let data = response {
                    self.orderDetails = try JSONDecoder().decode(OrderDetailsModel.self, from: data)
                }
            } catch {
                return
            }
            
            DispatchQueue.main.async {
                self.displayInfo()
            }
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditSegue" {
            let editView = segue.destination as! EditOrderTableViewController
            editView.orderModel = orderDetails
        }
        
        if segue.identifier == "DocumentSegue" {
            let docView = segue.destination as! DocumentViewController
            docView.orderId = orderId
        }
    }
    
    @IBAction func reloadDetails(_ segue: UIStoryboardSegue) {
        let view = segue.destination as! OrderDetailsController
        view.getDetails()
    }
    
    @IBAction func showMapsOptions(_ sender: Any) {
        var customer = CustomerModel()
        customer.customerCity = orderDetails.customerCity
        customer.customerColony = orderDetails.customerColony
        customer.customerStreet = orderDetails.customerStreet
        customer.customerZipcode = orderDetails.customerZipcode
        customer.stateName = orderDetails.stateName
        customer.countryName = orderDetails.countryName
        alerts.showMapsOptions(self, customer: customer)
    }
    
    @IBAction func showPhoneOptions(_ sender: Any) {
        var customer = CustomerModel()
        customer.customerPhone = orderDetails.customerPhone
        alerts.showPhoneOptions(self, customer: customer)
    }
    
}
