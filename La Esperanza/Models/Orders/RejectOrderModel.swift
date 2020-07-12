//
//  RejectOrderModel.swift
//  La Esperanza
//
//  Created by Efrain Garcia Rocha on 12/07/20.
//  Copyright © 2020 Efrain Garcia Rocha. All rights reserved.
//

import UIKit

struct RejectOrderModel: BaseModel {
    var errors: [String]
    var message: String
    var orderId: CLongLong
    var rejectReason: String
    
    init() {
        errors = []
        message = ""
        orderId = 0
        rejectReason = ""
    }
}
