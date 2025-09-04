//
//  DeviceModel.swift
//  La Esperanza
//
//  Created by Efrain Garcia Rocha on 21/07/20.
//  Copyright © 2020 Efrain Garcia Rocha. All rights reserved.
//

import Foundation

struct DeviceModel: Encodable, Decodable {
    var deviceId: Int = 0
    var userId: Int = 0
    var devicePushAuth: String = "Apple"
    var devicePushEndpoint: String = "Apple"
    var devicePushP256dh: String = ""
    var deviceNotificationCount: Int = 0
    var deviceRegistrationDate: String?
    var deviceValid: Bool = true
}
