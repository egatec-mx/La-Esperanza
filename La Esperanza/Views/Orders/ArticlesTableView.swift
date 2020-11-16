//
//  ArticlesView.swift
//  La Esperanza
//
//  Created by Efrain Garcia Rocha on 07/07/20.
//  Copyright © 2020 Efrain Garcia Rocha. All rights reserved.
//

import UIKit

class ArticlesTableView: UITableView, UITableViewDelegate, UITableViewDataSource {
    var articles: [ArticlesModel] = []
    var selectedIndex: IndexPath = IndexPath()
            
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ArticlesTableViewCell = tableView.dequeueReusableCell(withIdentifier: "ArticlesCell") as! ArticlesTableViewCell
        
        let article = articles[indexPath.row]
        
        let numberFormatter: NumberFormatter = NumberFormatter()
        numberFormatter.allowsFloats = true
        numberFormatter.alwaysShowsDecimalSeparator = true
        numberFormatter.generatesDecimalNumbers = true
        numberFormatter.minimumFractionDigits = 2
        numberFormatter.maximumFractionDigits = 2
        
        cell.LabelQuantity.text = numberFormatter.string(for: article.orderDetailQuantity)
        cell.LabelProduct.text = article.productName
        
        let format = NumberFormatter()
        format.numberStyle = .currency
        format.locale = Locale(identifier: UserDefaults.standard.string(forKey: "DEFAULT_LOCALE")!)
        cell.LabelPrice.text = format.string(for: article.orderDetailTotal)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        tableView.beginUpdates()
        
        switch editingStyle {
        case .delete:
            articles.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            if let parent = self.findViewController() as? EditOrderTableViewController {
                parent.orderModel.articles.remove(at: indexPath.row)
                parent.tableView.reloadData()
                parent.tableView.beginUpdates()
                parent.tableView.endUpdates()
            } else if let parent = self.findViewController() as? NewOrderTableViewController {
                parent.orderModel.articles.remove(at: indexPath.row)
                parent.tableView.reloadData()
                parent.tableView.beginUpdates()
                parent.tableView.endUpdates()
            }
        case .insert:
            articles.append(ArticlesModel())
            tableView.insertRows(at: [IndexPath(row: (articles.count - 1), section: 0)], with: .automatic)
            if let parent = self.findViewController() as? EditOrderTableViewController {
                parent.orderModel.articles.append(ArticlesModel())
                parent.tableView.reloadData()
                parent.tableView.beginUpdates()
                parent.tableView.endUpdates()
            } else if let parent = self.findViewController() as? NewOrderTableViewController {
                parent.orderModel.articles.append(ArticlesModel())
                parent.tableView.reloadData()
                parent.tableView.beginUpdates()
                parent.tableView.endUpdates()
            }
        default:
            return
        }
        
        tableView.endUpdates()
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if indexPath.row == articles.count - 1 { return .insert }
        return .delete
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        selectedIndex = indexPath
        return indexPath
    }
}
