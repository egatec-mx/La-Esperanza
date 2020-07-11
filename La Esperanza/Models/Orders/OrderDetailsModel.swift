//
//  OrderDetailsModel.swift
//  La Esperanza
//
//  Created by Efrain Garcia Rocha on 07/07/20.
//  Copyright © 2020 Efrain Garcia Rocha. All rights reserved.
//

import Foundation

struct OrderDetailsModel: Decodable, Encodable {
    var orderId: CLongLong
    var customerName: String
    var customerLastname: String
    var customerPhone: String
    var customerStreet: String
    var customerColony: String
    var customerCity: String
    var customerZipcode: Int
    var stateName: String
    var countryName: String
    var orderDate: String
    var paymentMethod: String
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
    var orderSubtotal: Decimal
    var orderTax: Decimal
    var orderTotal: Decimal
    var statusName: String
    var userFirstname: String
    var userLastname: String
    var articles: [ArticlesModel]
    var statusId: Int
    
    init() {
        orderId = 0
        customerName = ""
        customerLastname = ""
        customerPhone = ""
        customerStreet = ""
        customerColony = ""
        customerCity = ""
        customerZipcode = 0
        stateName = ""
        countryName = ""
        orderDate = ""
        paymentMethod = ""
        orderScheduleDate = nil
        orderCanceledDate = nil
        orderCanceledReason = nil
        orderDeliveredDate = nil
        orderDeliveryTax = 0.0
        orderNotes = nil
        orderProcessedDate = nil
        orderQrCode = nil
        orderRejectedDate = nil
        orderRejectedReason = nil
        orderStartedDate = nil
        orderSubtotal = 0.0
        orderTax = 0.0
        orderTotal = 0.0
        statusName = ""
        userFirstname = ""
        userLastname = ""
        articles = []
        statusId = 0
    }
}
