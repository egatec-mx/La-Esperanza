//
//  BackgroundExtension.swift
//  La Esperanza
//
//  Created by Efrain Garcia Rocha on 17/07/20.
//  Copyright © 2020 Efrain Garcia Rocha. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable class BaseUIView: UIView {
    
    @IBInspectable var BackgroundImage: UIImage? {
        didSet {
            backgroundColor = UIColor(patternImage: BackgroundImage!)
        }
    }
}

@IBDesignable class BaseUITableView: UITableView {
    
    @IBInspectable var BackgroundImage: UIImage? {
        didSet {
            backgroundColor = UIColor(patternImage: BackgroundImage!)
        }
    }
}
