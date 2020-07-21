//
//  CustomersTableViewController.swift
//  La Esperanza
//
//  Created by Efrain Garcia Rocha on 16/07/20.
//  Copyright © 2020 Efrain Garcia Rocha. All rights reserved.
//

import UIKit

class CustomersTableViewController: UITableViewController, UISearchBarDelegate {
    var webApi: WebApi = WebApi()
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
              
              warningAlert.addAction(UIAlertAction(title: NSLocalizedString("alert_delete_accept", tableName: "messages", comment: ""), style: .destructive, handler: { (action) -> Void in
                  
                  self.customerModel = self.searchList[indexPath.row]
                  self.customerModel.customerActive = false
                  
                  let data = try! JSONEncoder().encode(self.customerModel)
                  
                  self.webApi.DoPost("customers/update", jsonData: data, onCompleteHandler: {(response, error) -> Void in
                      guard error == nil else {
                          if (error as NSError?)?.code == 401 {
                              self.performSegue(withIdentifier: "TimeoutSegue", sender: self)
                          }
                          return
                      }
                      
                      guard response != nil else { return }
                      
                      self.getCustomers()
                
                  })
              }))
              
              self.present(warningAlert, animated: true, completion: nil)
            
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
        webApi.DoGet("customers", onCompleteHandler: {(response, error) -> Void in
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
        let mapsAlert = UIAlertController(title: NSLocalizedString("alert_navigation_title", tableName: "messages", comment: ""), message: NSLocalizedString("alert_navigation_message", tableName: "messages", comment: ""), preferredStyle: .actionSheet)
        
        let mapsAction = UIAlertAction(title: "Apple Maps", style: .default, handler: {(action) -> Void in
            if let row = self.selectedIndexPath?.row {
                let customer = self.searchList[row]
                let address = "\(customer.customerStreet.replacingOccurrences(of: " ", with: "+")),\(customer.customerColony.replacingOccurrences(of: " ", with: "+")),\(customer.customerCity.replacingOccurrences(of: " ", with: "+")),\(customer.stateName.replacingOccurrences(of: " ", with: "+")),\(customer.customerZipcode),\(customer.countryName)".folding(options: .diacriticInsensitive, locale: .current)
                if let mapsURL = URL(string: "https://maps.apple.com/?address=\(address)") {
                    UIApplication.shared.open(mapsURL, options: [:], completionHandler: nil)
                }
            }
        })
        
        let wazeAction = UIAlertAction(title: "Waze", style: .default, handler: {(action) -> Void in
            if let row = self.selectedIndexPath?.row {
                let customer = self.searchList[row]
                let address = "\(customer.customerStreet.replacingOccurrences(of: " ", with: "%20")),\(customer.customerColony.replacingOccurrences(of: " ", with: "%20")),\(customer.customerCity.replacingOccurrences(of: " ", with: "%20")),\(customer.stateName.replacingOccurrences(of: " ", with: "%20")),\(customer.customerZipcode),\(customer.countryName)".folding(options: .diacriticInsensitive, locale: .current)
                if let mapsURL = URL(string: "https://waze.com/ul?q=\(address)&navigate=yes") {
                    UIApplication.shared.open(mapsURL, options: [:], completionHandler: nil)
                }
            }
        })
        
        let googleMapsAction = UIAlertAction(title: "Google Maps", style: .default, handler: {(action) -> Void in
            if let row = self.selectedIndexPath?.row {
                let customer = self.searchList[row]
                let address = "\(customer.customerStreet.replacingOccurrences(of: " ", with: "+")),\(customer.customerColony.replacingOccurrences(of: " ", with: "+")),\(customer.customerCity.replacingOccurrences(of: " ", with: "+")),\(customer.stateName.replacingOccurrences(of: " ", with: "+")),\(customer.customerZipcode),\(customer.countryName)".folding(options: .diacriticInsensitive, locale: .current)
                if let googleUrl = URL(string: "comgooglemaps://?q=\(address)") {
                    UIApplication.shared.open(googleUrl, options: [:], completionHandler: nil)
                }
            }
        })
        
        let dismissAction = UIAlertAction(title: NSLocalizedString("alert_navigation_dismiss", tableName: "messages", comment: ""), style: .cancel, handler: nil)
        
        
        mapsAlert.addAction(wazeAction)
        mapsAlert.addAction(googleMapsAction)
        mapsAlert.addAction(mapsAction)
        mapsAlert.addAction(dismissAction)
        
        self.present(mapsAlert, animated: true, completion: nil)
        
    }
    
}
