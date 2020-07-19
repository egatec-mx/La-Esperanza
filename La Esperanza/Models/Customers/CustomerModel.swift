//
//  CustomerModel.swift
//  La Esperanza
//
//  Created by Efrain Garcia Rocha on 16/07/20.
//  Copyright © 2020 Efrain Garcia Rocha. All rights reserved.
//

import UIKit

struct CustomerModel: Encodable, Decodable, Equatable {
    var customerId: Int = -1
    var customerName: String = ""
    var customerLastname: String = ""
    var customerStreet: String = ""
    var customerColony: String = ""
    var customerCity: String = ""
    var stateName: String = ""
    var countryName: String = ""
    var customerZipcode: String = ""
    var customerActive: Bool = true
    var customerMail: String?
    var customerPhone: String = ""
    var stateId: Int = 0
}
