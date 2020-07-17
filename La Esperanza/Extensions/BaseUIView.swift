//
//  BackgroundExtension.swift
//  La Esperanza
//
//  Created by Efrain Garcia Rocha on 17/07/20.
//  Copyright © 2020 Efrain Garcia Rocha. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable class BaseUIViewController: UIViewController {
    
    @IBInspectable var BackgroundImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if BackgroundImage != nil {
            view.backgroundColor = UIColor(patternImage: BackgroundImage!)
        }
    }
}

@IBDesignable class BaseUITableViewController: UITableViewController {
    
    @IBInspectable var BackgroundImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if BackgroundImage != nil {
            view.backgroundColor = UIColor(patternImage: BackgroundImage!)
        }
    }
}
