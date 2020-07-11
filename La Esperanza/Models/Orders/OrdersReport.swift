//
//  OrdersReport.swift
//  La Esperanza
//
//  Created by Efrain Garcia Rocha on 03/07/20.
//  Copyright © 2020 Efrain Garcia Rocha. All rights reserved.
//

import UIKit

struct OrdersReport {
    var status: Int
    var orders: [OrdersModel]
    
    static func group(orders: [OrdersModel]) -> [OrdersReport] {
        let groups = Dictionary(grouping: orders) { (order) in
            return order.statusId
        }
        
        return groups.map({(key, values) in
            return OrdersReport(status: key, orders: values)
        })
    }
}
