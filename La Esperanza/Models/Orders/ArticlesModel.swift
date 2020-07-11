//
//  ArticlesModel.swift
//  La Esperanza
//
//  Created by Efrain Garcia Rocha on 07/07/20.
//  Copyright © 2020 Efrain Garcia Rocha. All rights reserved.
//

import Foundation

struct ArticlesModel: Encodable, Decodable {
    var orderDetailQuantity: Decimal
    var orderDetailTotal: Decimal
    var productName: String
}
