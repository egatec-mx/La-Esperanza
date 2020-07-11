//
//  LoginModel.swift
//  La Esperanza
//
//  Created by Efrain Garcia Rocha on 02/07/20.
//  Copyright © 2020 Efrain Garcia Rocha. All rights reserved.
//

import UIKit

struct LoginModel: BaseModel {
    var errors: [String]
    var message: String
    var userName: String
    var password: String
    var token: String
    
    init() {
        errors = []
        message = ""
        userName = ""
        password = ""
        token = ""
    }
}
