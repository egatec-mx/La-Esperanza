//
//  BaseModel.swift
//  La Esperanza
//
//  Created by Efrain Garcia Rocha on 02/07/20.
//  Copyright © 2020 Efrain Garcia Rocha. All rights reserved.
//

import UIKit

protocol BaseModel: Encodable, Decodable {
    var errors: [String] { get set}
    var message: String { get set}
}
