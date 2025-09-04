//
//  DocumentViewController.swift
//  La Esperanza
//
//  Created by Efrain Garcia Rocha on 05/08/20.
//  Copyright © 2020 Efrain Garcia Rocha. All rights reserved.
//

import UIKit
import PDFKit
import WebKit

class DocumentViewController: UIViewController {
    let webApi: WebApi = WebApi()
    let alerts: AlertsHelper = AlertsHelper()
    var orderId: CLongLong = 0
    var stringOrderId: String = ""
    var pdfPath: URL?
    
    @IBOutlet var pdfViewer: WKWebView!
    @IBOutlet var titleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stringOrderId = String(orderId).leftPadding(toLength: 6, withPad: "0")
        titleLabel.text = "#\(stringOrderId)"
        getPDF()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setToolbarHidden(true, animated: false)
    }
    
    func getPDF() {
        self.showWait({ [self] () -> Void in
            webApi.DoGet("print/order/\(orderId)", onCompleteHandler: { response, error -> Void in
                guard error == nil else {
                    if (error as NSError?)?.code == 401 {
                        hideWait {
                            performSegue(withIdentifier: "TimeoutSegue", sender: self)
                        }
                    }
                    return
                }
                
                guard response!.count > 0 else { return }
                
                var temp = FileManager.default.temporaryDirectory
                temp.removeAllCachedResourceValues()
                
                let pdfDocument: PDFDocument = PDFDocument(data: response!)!
                pdfPath = FileManager.default.temporaryDirectory.appendingPathComponent("\(stringOrderId).pdf")
                pdfDocument.write(to: pdfPath!)
                
                hideWait {
                    DispatchQueue.main.async {
                        pdfViewer.loadFileURL(pdfPath!, allowingReadAccessTo: FileManager.default.temporaryDirectory)
                    }
                }
            })
        })
    }
    
    func showSharePanel(shareItems: [Any]){
        let shareActivity: UIActivityViewController = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
        shareActivity.popoverPresentationController?.sourceView = view
        present(shareActivity, animated: true, completion: nil)
    }
    
    @IBAction func Cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func showShare(_ sender: Any) {
        let sharedItems: [Any] = [self.pdfPath!]
        showSharePanel(shareItems: sharedItems)
    }
}
