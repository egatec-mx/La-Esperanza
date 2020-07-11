//
//  OrderDetailsController.swift
//  La Esperanza
//
//  Created by Efrain Garcia Rocha on 03/07/20.
//  Copyright © 2020 Efrain Garcia Rocha. All rights reserved.
//

import UIKit

class OrderDetailsController: UITableViewController, UIContextMenuInteractionDelegate {
    let webApi: WebApi = WebApi()
    let numberFormatter: NumberFormatter = NumberFormatter()
    let dateFormatter: DateFormatter = DateFormatter()
    var phoneInteraction: UIContextMenuInteraction? = nil
    var orderId: CLongLong = 0
    var orderDetails: OrderDetailsModel = OrderDetailsModel()
    var moveOrderModel: MoveOrderModel = MoveOrderModel()
    var cancelOrderModel: CancelOrderModel = CancelOrderModel()
    var reasonTextField: UITextField!
        
    @IBOutlet var ImageQrCode: UIImageView!
    @IBOutlet var LabelOrder: UILabel!
    @IBOutlet var LabelCreationDate: UILabel!
    @IBOutlet var LabelCreationTime: UILabel!
    @IBOutlet var LabelPaymentMethod: UILabel!
    @IBOutlet var LabelDeliverDate: UILabel!
    @IBOutlet var LabelDeliverTime: UILabel!
    @IBOutlet var LabelCustomerName: UILabel!
    @IBOutlet var LabelPhoneNumber: UILabel!
    @IBOutlet var LabelAddress: UILabel!
    @IBOutlet var ArticlesTable: ArticlesTableView!
    @IBOutlet var LabelNotes: UILabel!
    @IBOutlet var LabelDeliveryTax: UILabel!
    @IBOutlet var LabelOrderTotal: UILabel!
    @IBOutlet var ScrollView: UIScrollView!
    @IBOutlet var MoveButton: UIBarButtonItem!
    @IBOutlet var DeleteButton: UIBarButtonItem!
    @IBOutlet var EditButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.setContentOffset(CGPoint(x: 0, y: -tableView.contentInset.top), animated: true)
        
        clearDataFromUI()
        
        dateFormatter.locale = Locale.current
        dateFormatter.calendar = Calendar.current
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        phoneInteraction = UIContextMenuInteraction(delegate: self)
        LabelPhoneNumber.addInteraction(phoneInteraction!)
        LabelPhoneNumber.isUserInteractionEnabled = true
        
        ArticlesTable.delegate = ArticlesTable.self
        ArticlesTable.dataSource = ArticlesTable.self
        
        self.navigationController?.setToolbarHidden(false, animated: true)
        
        webApi.DoGet("orders/\(orderId)", onCompleteHandler: {(response, error) -> Void in
            do {
                guard error == nil else { return }
                guard response != nil else { return }
                
                if let data = response {
                    self.orderDetails = try JSONDecoder().decode(OrderDetailsModel.self, from: data)
                    
                    DispatchQueue.main.async {
                        self.displayInfo()
                    }
                    
                }
            } catch {
                print("Error in details: \(error)")
                return
            }
        })
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 2 {
            return CGFloat((orderDetails.articles.count + 1) * 35)
        } else if indexPath.section == 4 {
            return (LabelNotes.frame.height * 0.85 < 150 ? 150 : LabelNotes.frame.height * 0.85)
        }
        
        return super.tableView(tableView, heightForRowAt: indexPath)
    }
    
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ -> UIMenu? in
            return self.createContextMenu()
        }
    }
        
    func displayInfo() {
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
            printDate.dateFormat = "dd/MM/YYYY"
            LabelCreationDate.text = printDate.string(for: cDate)
        }
        
        //Label Create Time
        if let cTime: Date = dateFormatter.date(from: orderDetails.orderDate) {
            let printTime: DateFormatter = DateFormatter()
            printTime.timeStyle = .short
            printTime.dateFormat = "hh:mm a"
            printTime.timeZone = TimeZone.current
            LabelCreationTime.text = printTime.string(for: cTime)
        }
        
        //Label Delivery Date
        if orderDetails.orderScheduleDate != nil {
            if let dDate: Date = dateFormatter.date(from: orderDetails.orderScheduleDate!) {
               let printDate: DateFormatter = DateFormatter()
               printDate.dateFormat = "dd/MM/YYYY"
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
               printTime.dateFormat = "hh:mm a"
               printTime.timeZone = TimeZone.current
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
        LabelPhoneNumber.text = formatPhoneNumber(orderDetails.customerPhone)
        
        //Label Address
        LabelAddress.text = """
                            \(orderDetails.customerStreet),
                            \(orderDetails.customerColony),
                            \(orderDetails.customerCity),
                            \(orderDetails.stateName), \(orderDetails.countryName), C.P \(orderDetails.customerZipcode)
                            """
        LabelAddress.frame.size = CGSize(width: LabelAddress.frame.width, height: heightForLabel(text: LabelAddress.text!, font: LabelAddress.font, width: LabelAddress.frame.width))
        
        //Articles
        ArticlesTable.articles = orderDetails.articles
        ArticlesTable.reloadData()
        
        //Label Totals
        numberFormatter.numberStyle = .currency
        numberFormatter.locale = Locale(identifier: "es_MX")
        
        if orderDetails.orderDeliveryTax != nil {
            LabelDeliveryTax.text = numberFormatter.string(for: orderDetails.orderDeliveryTax)
        } else {
            LabelDeliveryTax.text = "N/A"
        }
        
        LabelOrderTotal.text = numberFormatter.string(for: orderDetails.orderTotal)
        
        //Label Notes
        if orderDetails.orderNotes != nil {
            LabelNotes.text = orderDetails.orderNotes
            LabelNotes.frame.size = CGSize(width: LabelNotes.frame.width, height: heightForLabel(text: orderDetails.orderNotes!, font: LabelNotes.font, width: LabelNotes.frame.width))
        
            //Update Scroll View
            ScrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: (LabelNotes.frame.height * 1.15), right: 0)
        }
        
        if orderDetails.statusId >= 4 {
            MoveButton.isEnabled = false
            DeleteButton.isEnabled = false
            EditButton.isEnabled = false
        }
        
        tableView.beginUpdates()
        tableView.endUpdates()
    }
        
    func formatPhoneNumber(_ phoneNumber: String) -> String {
        var phone: String = ""
        var i = 0
        for n in phoneNumber {
            switch i {
            case 0:
                phone += "(\(n)"
            case 1:
                phone += "\(n)) "
            case 6:
                phone += " - \(n)"
            default:
                phone += String(n)
            }
            i += 1
        }
        return phone
    }
    
    func heightForLabel(text:String, font:UIFont, width:CGFloat) -> CGFloat{
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text

        label.sizeToFit()
        return label.frame.height
    }
    
    func createContextMenu() -> UIMenu {
        
        let callAction = UIAction(title: NSLocalizedString("menu_call", tableName: "messages", comment: ""), image: UIImage(systemName: "phone.arrow.up.right")) { _ in
            let url:URL = URL(string: "tel://\(self.orderDetails.customerPhone)")!
            UIApplication.shared.open(url as URL)
        }
                
        let whatsAppAction = UIAction(title: NSLocalizedString("menu_message", tableName: "messages", comment: ""), image: UIImage(systemName: "message")) { _ in
            let url:URL = URL(string: "whatsapp://+521\(self.orderDetails.customerPhone)")!
            UIApplication.shared.open(url as URL)
        }
        
        return UIMenu(title: NSLocalizedString("menu_actions", tableName: "messages", comment: ""), children: [callAction, whatsAppAction])
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
         
         //Label Customer Phone
         LabelPhoneNumber.text = ""
         
         //Label Address
         LabelAddress.text = ""
         
         //Label Totals
         LabelDeliveryTax.text = ""
         LabelOrderTotal.text = ""
         
         //Label Notes
         LabelNotes.text = ""
    }
    
    func showErrorAlert(_ message: String, onCompleteHandler: (() -> Void)?) {
        let alert = UIAlertController(title: NSLocalizedString("error_title", tableName: "messages", comment: ""), message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("alert_accept", tableName: "messages", comment: ""), style: .default, handler: { (action) -> Void in
            onCompleteHandler?()
        }))
        present(alert, animated: true, completion: nil)
    }
    
    func showSuccessAlert(_ message: String, onCompleteHandler: (() -> Void)?) {
        let alert = UIAlertController(title: NSLocalizedString("alert_success", tableName: "messages", comment: ""), message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("alert_accept", tableName: "messages", comment: ""), style: .default, handler: { (action) -> Void in
            onCompleteHandler?()
        }))
        present(alert, animated: true, completion: nil)
    }
    
    func configurationTextField(_ textField: UITextField) {
        self.reasonTextField = textField
        textField.placeholder = NSLocalizedString("alert_delete_reason", tableName: "messages", comment: "")
    }
    
    @IBAction func moveOrder(_ sender: Any) {
        do {
            moveOrderModel.orderId = orderId
                        
            let data = try JSONEncoder().encode(moveOrderModel)
            
            self.webApi.DoPost("orders/advance", jsonData: data, onCompleteHandler: {(response, error) -> Void in
                do {
                    guard error == nil else { return }
                    guard response != nil else { return }
                    
                    if let data = response {
                        self.moveOrderModel = try JSONDecoder().decode(MoveOrderModel.self, from: data)
                    }
                    
                    DispatchQueue.main.async {
                        if !self.moveOrderModel.message.isEmpty {
                            self.showSuccessAlert(self.moveOrderModel.message, onCompleteHandler: {() -> Void in
                                
                            })
                        }
                    }
                    
                } catch {
                    
                    print(error)
                    return
                    
                }
            })
            
        } catch {
                        
        }
    }
    
    @IBAction func cancelOrder(_ sender: Any) {
        
        let deleteAlert = UIAlertController(title: NSLocalizedString("alert_delete_title", tableName: "messages", comment: ""), message: NSLocalizedString("alert_delete_message", tableName: "messages", comment: ""), preferredStyle: .alert)
        
        deleteAlert.addTextField(configurationHandler: self.configurationTextField)
        
        deleteAlert.addAction(UIAlertAction(title: NSLocalizedString("alert_delete_accept", tableName: "messages", comment: ""), style: .default, handler: { (action) -> Void in
            
            self.cancelOrderModel.orderId = self.orderId
            self.cancelOrderModel.cancelReason = self.reasonTextField.text!
                            
            do {
                let data = try JSONEncoder().encode(self.cancelOrderModel)
                
                self.webApi.DoPost("orders/cancel", jsonData: data, onCompleteHandler: {(response, error) -> Void in
                    do {
                        guard error == nil else { return }
                        guard response != nil else { return }
                        
                        if let data = response {
                            self.cancelOrderModel = try JSONDecoder().decode(CancelOrderModel.self, from: data)
                        }
                        
                        DispatchQueue.main.async {
                            if !self.cancelOrderModel.message.isEmpty {
                                self.showSuccessAlert(self.cancelOrderModel.message, onCompleteHandler: {() -> Void in
                                    self.EditButton.isEnabled = false
                                    self.DeleteButton.isEnabled = false
                                    self.MoveButton.isEnabled = false
                                })
                            }
                        }
                        
                    } catch {
                        
                        print(error)
                        
                        return
                    }
                })
                                        
            } catch {
                
            }
        }))
        
        deleteAlert.addAction(UIAlertAction(title: NSLocalizedString("alert_delete_cancel", tableName: "messages", comment: ""), style: .destructive, handler: nil))
        
        self.present(deleteAlert, animated: true, completion: nil)
        
    }
    
}
