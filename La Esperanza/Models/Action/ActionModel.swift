//
//  BaseModel.swift
//  La Esperanza
//
//  Created by Efrain Garcia Rocha on 02/07/20.
//  Copyright © 2020 Efrain Garcia Rocha. All rights reserved.
//

import UIKit

protocol ActionModel: Encodable, Decodable, Equatable {
    var errors: [String] { get set}
    var message: String { get set}
}
