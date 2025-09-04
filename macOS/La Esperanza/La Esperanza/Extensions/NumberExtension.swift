//
//  NumberExtension.swift
//  La Esperanza
//
//  Created by Efrain Garcia Rocha on 19/02/21.
//  Copyright © 2021 Efrain Garcia Rocha. All rights reserved.
//

import Foundation

extension Decimal {
    
    func toStringFormat(_ style: NumberFormatter.Style) -> String {
        let format: NumberFormatter = NumberFormatter()
        format.locale = Locale.current
        format.numberStyle = style
        return format.string(for: self)!
    }
}
