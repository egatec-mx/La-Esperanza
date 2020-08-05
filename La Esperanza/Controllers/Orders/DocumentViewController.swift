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
    let alerts: AlertsHelper = AlertsHelper()
    let baseUrl: String = "https://esperanza.egatec.com.mx"
    var pdfPath: URL?
    var orderId: CLongLong = 0
    var stringOrderId: String = ""
    
    @IBOutlet var LabelTitle: UILabel!
    @IBOutlet var PDFViewer: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stringOrderId = String(orderId).leftPadding(toLength: 6, withPad: "0")
        LabelTitle.text = "#\(stringOrderId)"
        getPDF()
    }
    
    func getPDF() {
        self.showWait()
        
        let pdfRoute: String = "/print/printappleorder/\(orderId)"
        let pdfUrl: URL = URL(string: "\(baseUrl)\(pdfRoute)")!
        
        var pdfRequest = URLRequest(url: pdfUrl)
        pdfRequest.setValue(UserDefaults.standard.string(forKey: "PushToken"), forHTTPHeaderField: "Device")
        
        let pdfTask = URLSession.shared.dataTask(with: pdfRequest) { (data, response, error) -> Void in
            self.hideWait()
            
            guard data!.count > 0 else {
                self.alerts.showErrorAlert(self, message: NSLocalizedString("alert_document_empty", tableName: "messages", comment: ""), onComplete: nil)
                return
            }
            
            let pdfDocument: PDFDocument = PDFDocument(data: data!)!
            self.pdfPath = FileManager.default.temporaryDirectory.appendingPathComponent("\(self.stringOrderId).pdf")
            pdfDocument.write(to: self.pdfPath!)
            
            DispatchQueue.main.async {
                self.PDFViewer.loadFileURL(self.pdfPath!, allowingReadAccessTo: self.pdfPath!)
            }
        }
        pdfTask.resume()
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
