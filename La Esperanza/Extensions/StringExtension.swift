//
//  IntExtensions.swift
//  La Esperanza
//
//  Created by Efrain Garcia Rocha on 17/07/20.
//  Copyright © 2020 Efrain Garcia Rocha. All rights reserved.
//

import UIKit

extension String {
    
    func formatPhoneNumber() -> String {
        var phone: String = ""
        var i = 0
        for n in self {
            switch i {
            case 0:
                phone += "(\(n)"
            case 1:
                phone += "\(n)) "
            case 6:
                phone += " - \(n)"
            default:
                phone += String(n)
            }
            i += 1
        }
        return phone
    }
}
