//
//  OrdersViewController.swift
//  La Esperanza
//
//  Created by Efrain Garcia Rocha on 02/07/20.
//  Copyright © 2020 Efrain Garcia Rocha. All rights reserved.
//

import UIKit

class OrdersViewController: UITableViewController, UISearchBarDelegate {
    let webApi: WebApi = WebApi()
    let alerts: AlertsHelper = AlertsHelper()
    var ordersReport: [OrdersReport] = []
    var searchModel: SearchModel = SearchModel()
    var moveOrderModel: MoveOrderModel = MoveOrderModel()
    var cancelOrderModel: CancelOrderModel = CancelOrderModel()
    var rejectOrderModel: RejectOrderModel = RejectOrderModel()
    var selectedOrderId: CLongLong = 0
    var cancelReasonTextField: UITextField!
    var badgeValue: Int = 0
    
    @IBOutlet var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let tabParent = self.parent as? UITabBarController {
            tabParent.navigationItem.title = NSLocalizedString("tab_orders", tableName: "messages", comment: "")
        }
        
        self.refreshControl?.addTarget(self, action: #selector(getOrdersReport), for: .allEvents)
        
        self.getOrdersReport()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let tabParent = self.parent as? UITabBarController {
            tabParent.navigationItem.title = NSLocalizedString("tab_orders", tableName: "messages", comment: "")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setToolbarHidden(true, animated: true)
    }
        
    override func numberOfSections(in tableView: UITableView) -> Int {
        return ordersReport.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = self.ordersReport[section]
        return section.orders.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = self.ordersReport[indexPath.section]
        let order = section.orders[indexPath.row]
        
        let cell: OrderTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "OrdersCell", for: indexPath) as! OrderTableViewCell       
                
        switch section.status {
        case 1:
            cell.ImageStatus.image = UIImage(systemName: "bell")
            cell.ImageStatus.tintColor = UIColor.systemTeal
            cell.bottomBorder.backgroundColor = UIColor.systemTeal.cgColor
        case 2:
            cell.ImageStatus.image = UIImage(systemName: "clock")
            cell.ImageStatus.tintColor = UIColor.systemOrange
            cell.bottomBorder.backgroundColor = UIColor.systemOrange.cgColor
        case 3:
            cell.ImageStatus.image = UIImage(systemName: "car")
            cell.ImageStatus.tintColor = UIColor.systemPurple
            cell.bottomBorder.backgroundColor = UIColor.systemPurple.cgColor
        case 4:
            cell.ImageStatus.image = UIImage(systemName: "hand.thumbsup")
            cell.ImageStatus.tintColor = UIColor.systemGreen
            cell.bottomBorder.backgroundColor = UIColor.systemGreen.cgColor
        case 5:
            cell.ImageStatus.image = UIImage(systemName: "trash.slash")
            cell.ImageStatus.tintColor = UIColor.systemRed
            cell.bottomBorder.backgroundColor = UIColor.systemRed.cgColor
        case 6:
           cell.ImageStatus.image = UIImage(systemName: "hand.thumbsdown")
           cell.ImageStatus.tintColor = UIColor.systemPink
           cell.bottomBorder.backgroundColor = UIColor.systemPink.cgColor
        default:
            cell.ImageStatus.image = UIImage(systemName: "bell")
            cell.ImageStatus.tintColor = UIColor.systemGray
            cell.bottomBorder.backgroundColor = UIColor.systemGray.cgColor
        }

        cell.LabelOrderId.text = "#\(String(order.orderId).leftPadding(toLength: 6, withPad: "0"))"
        cell.LabelCustomer.text = order.customer
                
        let format = NumberFormatter()
        format.numberStyle = .currency
        format.locale = Locale(identifier: UserDefaults.standard.string(forKey: "DEFAULT_LOCALE")!)
        cell.LabelTotal.text = format.string(for: order.orderTotal)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let rect = CGRect(x: 0, y: 0, width: view.bounds.width, height: tableView.sectionHeaderHeight)
        let order = ordersReport[section]
        let headerView = UIView(frame: rect)
        let headerLabel = UILabel()
        
        switch order.status {
        case 1:
            headerView.backgroundColor = UIColor.systemTeal
            headerLabel.text = NSLocalizedString("status_new", tableName: "messages", comment: "")
        case 2:
            headerView.backgroundColor = UIColor.systemOrange
            headerLabel.text = NSLocalizedString("status_processing", tableName: "messages", comment: "")
        case 3:
            headerView.backgroundColor = UIColor.systemPurple
            headerLabel.text = NSLocalizedString("status_delivering", tableName: "messages", comment: "")
        case 4:
            headerView.backgroundColor = UIColor.systemGreen
            headerLabel.text = NSLocalizedString("status_completed", tableName: "messages", comment: "")
        case 5:
            headerView.backgroundColor = UIColor.systemRed
            headerLabel.text = NSLocalizedString("status_canceled", tableName: "messages", comment: "")
        case 6:
            headerView.backgroundColor = UIColor.systemPink
            headerLabel.text = NSLocalizedString("status_rejected", tableName: "messages", comment: "")
        default:
            headerView.backgroundColor = .clear
            headerLabel.text = ""
        }
        
        headerLabel.center.y = rect.height / 2
        headerLabel.center.x = 16
        headerLabel.layer.masksToBounds = true
        headerLabel.textColor = .white
        headerLabel.sizeToFit()
        headerView.addSubview(headerLabel)
                        
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35
    }
        
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = ordersReport[indexPath.section]
        let order = section.orders[indexPath.row]
        selectedOrderId = order.orderId
        performSegue(withIdentifier: "DetailSegue", sender: self)
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let cancelAction = UIContextualAction(style: .destructive, title: NSLocalizedString("swipe_right", tableName: "messages", comment: ""), handler: { (_, _, performed: (Bool) -> Void) in
            
            let deleteAlert = UIAlertController(title: NSLocalizedString("alert_delete_title", tableName: "messages", comment: ""), message: NSLocalizedString("alert_delete_message", tableName: "messages", comment: ""), preferredStyle: .alert)
            
            deleteAlert.addTextField(configurationHandler: self.configurationTextField)
            
            deleteAlert.addAction(UIAlertAction(title: NSLocalizedString("alert_delete_cancel", tableName: "messages", comment: ""), style: .destructive, handler: nil))
            
            deleteAlert.addAction(UIAlertAction(title: NSLocalizedString("alert_delete_accept", tableName: "messages", comment: ""), style: .default, handler: { (action) -> Void in
                
                self.cancelOrderModel.orderId = self.ordersReport[indexPath.section].orders[indexPath.row].orderId
                self.cancelOrderModel.cancelReason = self.cancelReasonTextField.text!
                self.showWait()
                                
                do {
                    let data = try JSONEncoder().encode(self.cancelOrderModel)
                    
                    self.webApi.DoPost("orders/cancel", jsonData: data, onCompleteHandler: {(response, error) -> Void in
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
                                self.hideWait()
                                self.cancelOrderModel = try JSONDecoder().decode(CancelOrderModel.self, from: data)
                            }
                            
                            if self.cancelOrderModel.errors.count > 0 {
                                self.alerts.processErrors(self, errors: self.cancelOrderModel.errors)
                            }
                            
                            if !self.cancelOrderModel.message.isEmpty {
                                self.alerts.showSuccessAlert(self, message: self.cancelOrderModel.message, onComplete: {() -> Void in
                                    self.getOrdersReport()
                                    self.tableView.reloadData()
                                })
                            }
                            
                        } catch {
                            print(error)
                            return
                        }
                    })
                                            
                } catch {
                    
                }
            }))
            
            self.present(deleteAlert, animated: true, completion: nil)
            
            performed(true)
            
        })
        
        let rejectAction = UIContextualAction(style: .normal, title: NSLocalizedString("swipe_right_reject", tableName: "messages", comment: ""), handler: { (_, _, performed: (Bool) -> Void) in
            
            let rejectAlert = UIAlertController(title: NSLocalizedString("alert_reject_title", tableName: "messages", comment: ""), message: NSLocalizedString("alert_reject_message", tableName: "messages", comment: ""), preferredStyle: .alert)
            
            rejectAlert.addTextField(configurationHandler: self.configurationTextField)
            
            rejectAlert.addAction(UIAlertAction(title: NSLocalizedString("alert_delete_cancel", tableName: "messages", comment: ""), style: .destructive, handler: nil))
            
            rejectAlert.addAction(UIAlertAction(title: NSLocalizedString("alert_delete_accept", tableName: "messages", comment: ""), style: .default, handler: { (action) -> Void in
                               
                self.rejectOrderModel.orderId = self.ordersReport[indexPath.section].orders[indexPath.row].orderId
                self.rejectOrderModel.rejectReason = self.cancelReasonTextField.text!
                self.showWait()
                                
                do {
                    let data = try JSONEncoder().encode(self.rejectOrderModel)
                    
                    self.webApi.DoPost("orders/reject", jsonData: data, onCompleteHandler: {(response, error) -> Void in
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
                                self.rejectOrderModel = try JSONDecoder().decode(RejectOrderModel.self, from: data)
                            }
                            
                            if self.rejectOrderModel.errors.count > 0 {
                                self.alerts.processErrors(self, errors: self.rejectOrderModel.errors)
                            }
                            
                            if !self.rejectOrderModel.message.isEmpty {
                                self.alerts.showSuccessAlert(self, message: self.cancelOrderModel.message, onComplete: {() -> Void in
                                    self.getOrdersReport()
                                    self.tableView.reloadData()
                                })
                            }
                            
                        } catch {
                            print(error)
                            return
                        }
                    })
                                            
                } catch {
                    return
                }
            }))
            
            self.present(rejectAlert, animated: true, completion: nil)
            
            performed(true)
            
        })
        
        rejectAction.backgroundColor = UIColor.systemPurple
        
        switch ordersReport[indexPath.section].status {
        case 1, 2:
            return UISwipeActionsConfiguration(actions: [cancelAction])
        case 3:
            return UISwipeActionsConfiguration(actions: [rejectAction, cancelAction])
        default:
            return UISwipeActionsConfiguration(actions: [])
        }
    }
    
    func configurationTextField(_ textField: UITextField) {
        self.cancelReasonTextField = textField
        textField.placeholder = NSLocalizedString("alert_delete_reason", tableName: "messages", comment: "")
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        switch ordersReport[indexPath.section].status {
        case 1, 2, 3:
            let moveAction = UIContextualAction(style: .normal, title: NSLocalizedString("swipe_left", tableName: "messages", comment: ""), handler: { (_, _, performed: (Bool) -> Void) in
                
                self.moveOrderModel.orderId = self.ordersReport[indexPath.section].orders[indexPath.row].orderId
                self.showWait()
                
                do {
                    let data = try JSONEncoder().encode(self.moveOrderModel)
                    
                    self.webApi.DoPost("orders/advance", jsonData: data, onCompleteHandler: {(response, error) -> Void in
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
                                self.moveOrderModel = try JSONDecoder().decode(MoveOrderModel.self, from: data)
                            }
                            
                            if self.moveOrderModel.errors.count > 0 {
                                self.alerts.processErrors(self, errors: self.moveOrderModel.errors)
                            }
                            
                            if !self.moveOrderModel.message.isEmpty {
                                self.alerts.showSuccessAlert(self, message: self.moveOrderModel.message, onComplete: {() -> Void in
                                    self.getOrdersReport()
                                    self.tableView.reloadData()
                                })
                            }
                            
                        } catch {
                            print(error)
                            return
                        }
                    })
                    
                    performed(true)
                    
                } catch {
                    performed(false)                    
                }
            })
                        
            moveAction.backgroundColor = .systemGreen
            
            return UISwipeActionsConfiguration(actions: [moveAction])
            
        default:
            return UISwipeActionsConfiguration(actions: [])
        }
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
    
    func searchBarResultsListButtonClicked(_ searchBar: UISearchBar) {
        performSegue(withIdentifier: "DetailSegue", sender: self)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
           getOrdersReport()
        } else if searchText.count >= 3 {
           getSearchResults(searchText)
        }
    }
            
    @objc func getOrdersReport() {
        webApi.DoGet("orders", onCompleteHandler: { (response, error) -> Void in
            do {
                                
                guard error == nil else {
                    if (error as NSError?)?.code == 401 {
                        self.performSegue(withIdentifier: "TimeoutSegue", sender: self)
                    }
                    return
                }
                
                guard response != nil else { return }
                
                if let data = response {
                    let orders = try JSONDecoder().decode([OrdersModel].self, from: data)
                    self.badgeValue = orders.filter{$0.statusId == 1}.count
                    self.ordersReport = OrdersReport.group(orders: orders).sorted(by: { (a, b) -> Bool in
                        return a.status < b.status
                    })
                }
                
                DispatchQueue.main.async {
                    
                    self.tableView.reloadData()
                    self.refreshControl?.endRefreshing()
                    
                    if self.badgeValue > 0 {
                        self.tabBarItem.badgeValue = String(self.badgeValue)
                        self.tabBarItem.badgeColor = UIColor.red
                    } else {
                        self.tabBarItem.badgeValue = ""
                        self.tabBarItem.badgeColor = UIColor.clear
                    }
                }
            } catch {
                return
            }
        })
    }
        
    func getSearchResults(_ searchTerm: String) {
        searchModel.searchTerm = String(searchTerm)
        
        let data = try! JSONEncoder().encode(searchModel)
        
        webApi.DoPost("orders/search", jsonData: data, onCompleteHandler: { (response, error) -> Void in
            do {
                
                guard error == nil else {
                    if (error as NSError?)?.code == 401 {
                        self.performSegue(withIdentifier: "TimeoutSegue", sender: self)
                    }
                    return
                }
                
                guard response != nil else { return }
                
                if let data = response {
                    let results = try JSONDecoder().decode([OrdersModel].self, from: data)
                    self.ordersReport = OrdersReport.group(orders: results)
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        self.refreshControl?.endRefreshing()
                    }
                    
                }
            } catch {
                return
            }
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let details = segue.destination as? OrderDetailsController else { return }
        details.orderId = selectedOrderId
    }
    
    @IBAction func reloadOrdersView(_ sender: UIStoryboardSegue) {
        guard let ordersView = sender.destination as? OrdersViewController else { return }
        ordersView.getOrdersReport()
        ordersView.tableView.reloadData()
    }
}
