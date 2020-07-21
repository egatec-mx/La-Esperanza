//
//  ArticlesModel.swift
//  La Esperanza
//
//  Created by Efrain Garcia Rocha on 07/07/20.
//  Copyright © 2020 Efrain Garcia Rocha. All rights reserved.
//

import Foundation

struct ArticlesModel: Encodable, Decodable {
    var orderDetailId: CLongLong = 0
    var orderDetailQuantity: Double = 1
    var orderDetailPrice: Decimal = 0
    var orderDetailTotal: Decimal = 0
    var productId: Int = 0
    var productName: String = "--- Seleccione ---"
}
