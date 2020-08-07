//
//  TodaySalesModel.swift
//  La Esperanza
//
//  Created by Efrain Garcia Rocha on 07/08/20.
//  Copyright © 2020 Efrain Garcia Rocha. All rights reserved.
//

import Foundation

struct TodaySalesModel: Encodable, Decodable {
    var count: Int = 0
    var deliveryTaxTotal: Decimal = 0.0
    var total: Decimal = 0.0
}
