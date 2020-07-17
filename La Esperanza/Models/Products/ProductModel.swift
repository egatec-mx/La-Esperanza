//
//  ProductsList.swift
//  La Esperanza
//
//  Created by Efrain Garcia Rocha on 15/07/20.
//  Copyright © 2020 Efrain Garcia Rocha. All rights reserved.
//

import UIKit

struct ProductModel: Encodable, Decodable, Equatable {
    var productId: Int = 0
    var productName: String = ""
    var productPrice: Decimal = 0.00
    var productActive: Bool = true
}
