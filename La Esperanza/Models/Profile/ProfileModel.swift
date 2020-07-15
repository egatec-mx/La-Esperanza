//
//  ProfileModel.swift
//  La Esperanza
//
//  Created by Efrain Garcia Rocha on 13/07/20.
//  Copyright © 2020 Efrain Garcia Rocha. All rights reserved.
//

import UIKit

struct ProfileModel: Encodable, Decodable {
    var name: String
    var role: String
    
    init() {
        name = ""
        role = ""
    }
}
