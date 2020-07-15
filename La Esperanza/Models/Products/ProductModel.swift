//
//  ProductsList.swift
//  La Esperanza
//
//  Created by Efrain Garcia Rocha on 15/07/20.
//  Copyright © 2020 Efrain Garcia Rocha. All rights reserved.
//

import UIKit

struct ProductModel: Encodable, Decodable, Equatable {
    var productId: Int
    var productName: String
    var productPrice: Decimal
    var productActive: Bool
    
    init() {
        productId = 0
        productName = ""
        productPrice = 0.0
        productActive = true
    }
}
