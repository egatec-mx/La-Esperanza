//
//  OrderDetailsModel.swift
//  La Esperanza
//
//  Created by Efrain Garcia Rocha on 07/07/20.
//  Copyright © 2020 Efrain Garcia Rocha. All rights reserved.
//

import Foundation

struct OrderDetailsModel: Decodable, Encodable {
    var orderId: CLongLong = 0
    var customerName: String = ""
    var customerLastname: String = ""
    var customerPhone: String = ""
    var customerStreet: String = ""
    var customerColony: String = ""
    var customerCity: String = ""
    var customerZipcode: String = ""
    var stateName: String = ""
    var countryName: String = ""
    var orderDate: String = ""
    var paymentMethod: String = ""
    var orderScheduleDate: String?
    var orderCanceledDate: String?
    var orderCanceledReason: String?
    var orderDeliveredDate: String?
    var orderDeliveryTax: Decimal?
    var orderNotes: String?
    var orderProcessedDate: String?
    var orderQrCode: String?
    var orderRejectedDate: String?
    var orderRejectedReason: String?
    var orderStartedDate: String?
    var orderSubtotal: Decimal = 0.0
    var orderTax: Decimal = 0.0
    var orderTotal: Decimal = 0.0
    var statusName: String = ""
    var userFirstname: String = ""
    var userLastname: String = ""
    var articles: [ArticlesModel] = []
    var statusId: Int = 0
}
