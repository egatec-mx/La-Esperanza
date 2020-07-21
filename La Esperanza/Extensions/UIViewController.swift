//
//  WaitUIView.swift
//  La Esperanza
//
//  Created by Efrain Garcia Rocha on 21/07/20.
//  Copyright © 2020 Efrain Garcia Rocha. All rights reserved.
//

import UIKit

var waitViewController: UIViewController?

extension UIViewController {
    func showWait() {
        let waitModal = storyboard?.instantiateViewController(withIdentifier: "WaitView") as! WaitViewController
        waitModal.modalPresentationStyle = .overFullScreen
        waitModal.preferredContentSize = CGSize(width: view.bounds.width, height: view.bounds.height)
        waitModal.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        waitViewController = waitModal
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: { () -> Void in
            self.present(waitModal, animated: true, completion: nil)
        })
        
    }
    
    func hideWait() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: { () -> Void in
            waitViewController?.dismiss(animated: true, completion: nil)
        })
    }
}
