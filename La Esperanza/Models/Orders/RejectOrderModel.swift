//
//  RejectOrderModel.swift
//  La Esperanza
//
//  Created by Efrain Garcia Rocha on 12/07/20.
//  Copyright © 2020 Efrain Garcia Rocha. All rights reserved.
//

import UIKit

struct RejectOrderModel: ActionModel {
    var errors: [String] = []
    var message: String = ""
    var orderId: CLongLong = 0
    var rejectReason: String = ""
}
