//
//  OrderTableViewCell.swift
//  La Esperanza
//
//  Created by Efrain Garcia Rocha on 03/07/20.
//  Copyright © 2020 Efrain Garcia Rocha. All rights reserved.
//

import UIKit

class OrderTableViewCell: UITableViewCell {
    let bottomBorder = CALayer()
    
    @IBOutlet var LabelOrderId: UILabel!
    @IBOutlet var LabelCustomer: UILabel!
    @IBOutlet var LabelTotal: UILabel!
    @IBOutlet var ImageStatus: UIImageView!
        
    override func awakeFromNib() {
        super.awakeFromNib()
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        bottomBorder.frame = CGRect(x: 0.0, y: self.bounds.height - 2, width: self.bounds.width, height: 2)
        layer.masksToBounds = true
        layer.cornerRadius = 0
        layer.borderWidth = 0
        layer.addSublayer(bottomBorder)
        setNeedsDisplay()
    }
}
