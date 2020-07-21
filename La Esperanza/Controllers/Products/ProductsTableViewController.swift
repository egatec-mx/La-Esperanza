//
//  ProductsTableViewController.swift
//  La Esperanza
//
//  Created by Efrain Garcia Rocha on 15/07/20.
//  Copyright © 2020 Efrain Garcia Rocha. All rights reserved.
//

import UIKit

class ProductsTableViewController: UITableViewController, UISearchBarDelegate {
    let webApi: WebApi = WebApi()
    let alerts: AlertsHelper = AlertsHelper()
    var productsList: [ProductModel] = []
    var searchList: [ProductModel] = []
    var productModel: ProductModel = ProductModel()
    var selectedProductId: Int = 0
    
    @IBOutlet var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        self.refreshControl?.addTarget(self, action: #selector(getProducts), for: .allEvents)
               
        getProducts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setToolbarHidden(false, animated: true)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductCell", for: indexPath)
        let product = searchList[indexPath.row]
        let moneyFormat = NumberFormatter()
        moneyFormat.numberStyle = .currency
        moneyFormat.locale = Locale(identifier: "es-MX")
        cell.textLabel?.text = product.productName
        cell.detailTextLabel?.text = moneyFormat.string(for: product.productPrice)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            let warningAlert = UIAlertController(title: NSLocalizedString("alert_warning_title", tableName: "messages", comment: ""), message: NSLocalizedString("alert_product_delete", tableName: "messages", comment: ""), preferredStyle: .alert)
            
            warningAlert.addAction(UIAlertAction(title: NSLocalizedString("alert_delete_cancel", tableName: "messages", comment: ""), style: .cancel, handler: nil))
            
            warningAlert.addAction(UIAlertAction(title: NSLocalizedString("alert_delete_accept", tableName: "messages", comment: ""), style: .destructive, handler: { (action) -> Void in
                
                self.productModel = self.searchList[indexPath.row]
                self.productModel.productActive = false
                self.showWait()
                
                let data = try! JSONEncoder().encode(self.productModel)
                
                self.webApi.DoPost("products/update", jsonData: data, onCompleteHandler: {(response, error) -> Void in
                    guard error == nil else {
                        if (error as NSError?)?.code == 401 {
                            self.hideWait()
                            self.performSegue(withIdentifier: "TimeoutSegue", sender: self)
                        }
                        return
                    }
                    
                    guard response != nil else { return }
                    
                    self.hideWait()
                    
                    if self.productModel.errors.count > 0 {
                        self.alerts.processErrors(self, errors: self.productModel.errors)
                    }
                    
                    if !self.productModel.message.isEmpty {
                        self.alerts.showSuccessAlert(self, message: self.productModel.message, onComplete: nil)
                    }
                    
                    self.getProducts()
                    
                })
            }))
            
            self.present(warningAlert, animated: true, completion: nil)
            
        default:
            return
        }
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        selectedProductId = searchList[indexPath.row].productId
        return indexPath
    }
    
    @objc func getProducts() {
        webApi.DoGet("products", onCompleteHandler: {(response, error) -> Void in
            do {
                                
                guard error == nil else {
                    if (error as NSError?)?.code == 401 {
                        self.performSegue(withIdentifier: "TimeoutSegue", sender: self)
                    }
                    return
                }
                
                guard response != nil else { return }
                
                if let data = response {
                    self.productsList = try JSONDecoder().decode([ProductModel].self, from: data)
                    self.searchList = self.productsList
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
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            searchList = productsList
        } else {
            searchList = productsList.filter({ $0.productName.localizedCaseInsensitiveContains(searchText) })
        }
        tableView.reloadData()
    }
    
    @IBAction func reloadProductsList(_ segue: UIStoryboardSegue){
        let destination = segue.destination as! ProductsTableViewController
        destination.selectedProductId = 0
        destination.getProducts()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditProductSegue" {
            let editView = segue.destination as! EditProductViewController
            editView.productModel.productId = selectedProductId
        }
    }

}
