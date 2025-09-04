//
//  ArticlesViewTableCell.swift
//  La Esperanza
//
//  Created by Efrain Garcia Rocha on 07/07/20.
//  Copyright © 2020 Efrain Garcia Rocha. All rights reserved.
//

import UIKit

class ArticlesTableViewCell: UITableViewCell  {
    
    @IBOutlet var LabelQuantity: UILabel!
    @IBOutlet var LabelProduct: UILabel!
    @IBOutlet var LabelPrice: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
