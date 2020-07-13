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
            
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let cell: ArticlesTableViewCell = tableView.dequeueReusableCell(withIdentifier: "ArticlesCell", for: indexPath) as! ArticlesTableViewCell
            
        let article = articles[indexPath.row]
        
        cell.LabelQuantity.text = "\(article.orderDetailQuantity)"
        cell.LabelProduct.text = article.productName
        
        let format = NumberFormatter()
        format.numberStyle = .currency
        format.locale = Locale(identifier: "es_MX")
        cell.LabelPrice.text = format.string(for: article.orderDetailTotal)
        
        return cell
    }
    
}
