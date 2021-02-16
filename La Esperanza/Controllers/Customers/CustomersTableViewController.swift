//
//  CustomersTableViewController.swift
//  La Esperanza
//
//  Created by Efrain Garcia Rocha on 16/07/20.
//  Copyright © 2020 Efrain Garcia Rocha. All rights reserved.
//

import UIKit

class CustomersTableViewController: UITableViewController, UISearchBarDelegate {
    let webApi: WebApi = WebApi()
    let alerts: AlertsHelper = AlertsHelper()
    var customersList: [CustomerModel] = []
    var searchList: [CustomerModel] = []
    var customerModel: CustomerModel = CustomerModel()
    var selectedCustomerId: Int = 0
    var selectedIndexPath: IndexPath?
    
    @IBOutlet var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        self.refreshControl?.addTarget(self, action: #selector(getCustomers), for: .allEvents)
        
        getCustomers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      
      self.navigationController?.setToolbarHidden(false, animated: true)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return searchList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomerCell", for: indexPath) as! CustomerTableViewCell
        let customer = searchList[indexPath.row]
        cell.CustomerName.text = "\(customer.customerName) \(customer.customerLastname)"
        cell.CustomerPhone.text = customer.customerPhone.formatPhoneNumber()
        cell.CustomerMail.text = customer.customerMail
        cell.CustomerAddress.text = """
                                    \(customer.customerStreet),
                                    \(customer.customerColony),
                                    \(customer.customerCity), \(customer.stateName),
                                    \(customer.countryName), C.P \(customer.customerZipcode)
                                    """
        cell.CustomerAddress.frame.size = CGSize(width: cell.CustomerAddress.frame.width, height: cell.CustomerAddress.height(text: cell.CustomerAddress.text!, font: cell.CustomerAddress.font, width: cell.CustomerAddress.frame.width))
        return cell
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
          case .delete:
              
            let warningAlert = UIAlertController(title: NSLocalizedString("alert_warning_title", tableName: "messages", comment: ""), message: NSLocalizedString("alert_customer_delete", tableName: "messages", comment: ""), preferredStyle: .alert)
              
            warningAlert.addAction(UIAlertAction(title: NSLocalizedString("alert_delete_cancel", tableName: "messages", comment: ""), style: .cancel, handler: nil))
              
            warningAlert.addAction(UIAlertAction(title: NSLocalizedString("alert_delete_accept", tableName: "messages", comment: ""), style: .destructive, handler: { [self] action in
                  
                customerModel = searchList[indexPath.row]
                customerModel.customerActive = false
                
                showWait { [self] in
                    do {
                        let data = try JSONEncoder().encode(customerModel)
                        webApi.DoPost("customers/update", jsonData: data, onCompleteHandler: { response, error in
                            guard error == nil else {
                                if (error as NSError?)?.code == 401 {
                                    hideWait {
                                        performSegue(withIdentifier: "TimeoutSegue", sender: self)
                                    }
                                }
                                return
                            }
                            
                            guard response != nil else { return }
                            
                            hideWait {
                                if customerModel.errors.count > 0 {
                                    alerts.processErrors(self, errors: customerModel.errors)
                                }
                                
                                if !customerModel.message.isEmpty {
                                    alerts.showSuccessAlert(self, message: customerModel.message, onComplete: nil)
                                 }
                                
                                getCustomers()
                            }
                          })
                    } catch {
                        hideWait {
                            return
                        }
                    }
                }
              }))
              
              present(warningAlert, animated: true, completion: nil)
            
          default:
              return
          }
    }

    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        selectedCustomerId = searchList[indexPath.row].customerId
        selectedIndexPath = indexPath
        return indexPath
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.isEditing {
            performSegue(withIdentifier: "EditSegue", sender: nil)
        }
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        view.endEditing(true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        view.endEditing(true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            searchList = customersList
        } else {
            searchList = customersList.filter({ $0.customerName.localizedCaseInsensitiveContains(searchText) || $0.customerLastname.localizedCaseInsensitiveContains(searchText) })
        }
        tableView.reloadData()
    }
    
    @IBAction func reloadCustomersList(_ segue: UIStoryboardSegue){
        let destination = segue.destination as! CustomersTableViewController
        destination.selectedCustomerId = 0
        destination.getCustomers()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditSegue" {
            let editView = segue.destination as! EditCustomerTableViewController
            editView.customerModel.customerId = selectedCustomerId
        }
    }
    
    @objc func getCustomers() {
        webApi.DoGet("customers", onCompleteHandler: { response, error in
            do {                                
                guard error == nil else {
                    if (error as NSError?)?.code == 401 {
                        self.performSegue(withIdentifier: "TimeoutSegue", sender: self)
                    }
                    return
                }
                
                guard response != nil else { return }
                
                if let data = response {
                    self.customersList = try JSONDecoder().decode([CustomerModel].self, from: data)
                    self.searchList = self.customersList
                }
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.refreshControl?.endRefreshing()
                    self.tableView.beginUpdates()
                    self.tableView.endUpdates()
                }
            } catch {
                return
            }
        })
    }
    
    @IBAction func openMaps(_ sender: Any) {
        if let row = self.selectedIndexPath?.row {
            let customer = self.searchList[row]
            self.alerts.showMapsOptions(self, customer: customer)
        }
    }
    
}
