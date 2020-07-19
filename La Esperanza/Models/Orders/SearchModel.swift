//
//  SearchModel.swift
//  La Esperanza
//
//  Created by Efrain Garcia Rocha on 03/07/20.
//  Copyright © 2020 Efrain Garcia Rocha. All rights reserved.
//

import Foundation

struct SearchModel: ActionModel {
    var errors: [String] = []
    var message: String = ""
    var searchTerm: String = ""
}
