//
//  OrderTableViewCell.swift
//  La Esperanza
//
//  Created by Efrain Garcia Rocha on 03/07/20.
//  Copyright © 2020 Efrain Garcia Rocha. All rights reserved.
//

import UIKit

class OrderTableViewCell: UITableViewCell {

    @IBOutlet var LabelOrderId: UILabel!
    @IBOutlet var LabelCustomer: UILabel!
    @IBOutlet var LabelTotal: UILabel!
    @IBOutlet var ImageStatus: UIImageView!
        
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
