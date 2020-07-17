//
//  OrdersModel.swift
//  La Esperanza
//
//  Created by Efrain Garcia Rocha on 03/07/20.
//  Copyright © 2020 Efrain Garcia Rocha. All rights reserved.
//

import  UIKit

struct OrdersModel: Encodable, Decodable {
    var orderId: CLongLong = 0
    var orderDate: String = ""
    var orderTotal: Decimal = 0.00
    var customer: String = ""
    var statusId: Int = 0
}
