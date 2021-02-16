//
//  WaitViewController.swift
//  La Esperanza
//
//  Created by Efrain Garcia Rocha on 21/07/20.
//  Copyright © 2020 Efrain Garcia Rocha. All rights reserved.
//

import UIKit

class WaitViewController: UIViewController {
    
    @IBOutlet var waitLoaderView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        waitLoaderView.layer.cornerRadius = 20
        waitLoaderView.layer.shadowRadius = 20        
    }
}
