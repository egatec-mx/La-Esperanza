//
//  CancelOrderModel.swift
//  La Esperanza
//
//  Created by Efrain Garcia Rocha on 09/07/20.
//  Copyright © 2020 Efrain Garcia Rocha. All rights reserved.
//


import UIKit

struct CancelOrderModel: BaseModel, Encodable, Decodable {
    var errors: [String]
    var message: String
    var orderId: CLongLong
    var cancelReason: String
    
    init() {
        errors = []
        message = ""
        orderId = 0
        cancelReason = ""
    }
}
