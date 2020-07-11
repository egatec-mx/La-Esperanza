//
//  OrdersModel.swift
//  La Esperanza
//
//  Created by Efrain Garcia Rocha on 03/07/20.
//  Copyright © 2020 Efrain Garcia Rocha. All rights reserved.
//

import  UIKit

struct OrdersModel: Encodable, Decodable {
    var orderId: CLongLong
    var orderDate: String
    var orderTotal: Decimal
    var customer: String
    var statusId: Int
    
    init() {
        orderId = 0
        orderDate = ""
        orderTotal = 0.0
        customer = ""
        statusId = 0
    }
}
