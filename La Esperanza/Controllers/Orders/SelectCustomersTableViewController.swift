//
//  SelectCustomersTableViewController.swift
//  La Esperanza
//
//  Created by Efrain Garcia Rocha on 19/07/20.
//  Copyright © 2020 Efrain Garcia Rocha. All rights reserved.
//

import UIKit

class SelectCustomersTableViewController: UITableViewController, UISearchBarDelegate {
    let webApi: WebApi = WebApi()
    var customerList: [CustomerModel] = []
    var searchList: [CustomerModel] = []
    var selectedCustomer: Int = 0
    var selectedCustomerFullName: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomerCell", for: indexPath)
        cell.textLabel?.text = "\(searchList[indexPath.row].customerName) \(searchList[indexPath.row].customerLastname)"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedCustomer = searchList[indexPath.row].customerId
        selectedCustomerFullName = "\(searchList[indexPath.row].customerName) \(searchList[indexPath.row].customerLastname)"
        performSegue(withIdentifier: "GoBackSegue", sender: nil)
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
            searchList = customerList
        } else {
            searchList = customerList.filter({ $0.customerName.localizedCaseInsensitiveContains(searchText) || $0.customerLastname.localizedCaseInsensitiveContains(searchText) })
        }
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GoBackSegue" {
            let editView = segue.destination as! EditOrderTableViewController
            editView.orderModel.customerId = selectedCustomer
            editView.customerLabel.text = selectedCustomerFullName
        } else if segue.identifier == "NewSegue" {
            let newView = segue.destination as! NewCustomerTableViewController
            newView.sourceSegue = "NewSegue"
        }
    }
    
    @IBAction func reloadSelectCustomers(_ segue: UIStoryboardSegue) {
        let destination = segue.destination as! SelectCustomersTableViewController
        destination.selectedCustomerFullName = ""
        destination.selectedCustomer = 0
        destination.getCustomers()
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
                    self.customerList = try JSONDecoder().decode([CustomerModel].self, from: data)
                    self.searchList = self.customerList
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
}
