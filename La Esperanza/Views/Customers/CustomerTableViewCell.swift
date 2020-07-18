//
//  CustomerTableViewCell.swift
//  La Esperanza
//
//  Created by Efrain Garcia Rocha on 17/07/20.
//  Copyright © 2020 Efrain Garcia Rocha. All rights reserved.
//

import UIKit

class CustomerTableViewCell: UITableViewCell {
    @IBOutlet var CustomerName: UILabel!
    @IBOutlet var CustomerPhone: UILabel!
    @IBOutlet var CustomerMail: UILabel!
    @IBOutlet var CustomerAddress: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
