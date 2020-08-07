//
//  SalesReportViewController.swift
//  La Esperanza
//
//  Created by Efrain Garcia Rocha on 07/08/20.
//  Copyright © 2020 Efrain Garcia Rocha. All rights reserved.
//

import UIKit
import WebKit
import PDFKit

class SalesReportViewController: UIViewController {
    let webApi: WebApi = WebApi()
    let alerts: AlertsHelper = AlertsHelper()
    var reportDate: String = ""
    var reportName: String = ""
    var reportPath: URL?

    @IBOutlet var pdfViewer: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        reportName = reportDate.replacingOccurrences(of: "-", with: "_")
        getReport()
    }
    
    func getReport() {
        self.showWait()
        
        webApi.DoGet("print/sales/\(reportDate)", onCompleteHandler: { (response, error) -> Void in
            self.hideWait()
            
            guard error == nil else {
                if (error as NSError?)?.code == 401 {
                    self.performSegue(withIdentifier: "TimeoutSegue", sender: self)
                }
                return
            }
            
            guard response!.count > 0 else {
                self.alerts.showErrorAlert(self, message: NSLocalizedString("alert_report_notfound", tableName: "messages", comment: ""), onComplete: nil)
                return
            }
            
            let pdfDocument: PDFDocument = PDFDocument(data: response!)!
            self.reportPath = FileManager.default.temporaryDirectory.appendingPathComponent("\(self.reportName).pdf")
            pdfDocument.write(to: self.reportPath!)
            
            DispatchQueue.main.async {
                self.pdfViewer.loadFileURL(self.reportPath!, allowingReadAccessTo: FileManager.default.temporaryDirectory)
            }
        })
    }
    
    func sharePanel(shareItems: [Any]){
        let shareActivity: UIActivityViewController = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
        shareActivity.popoverPresentationController?.sourceView = view
        present(shareActivity, animated: true, completion: nil)
    }
    
    @IBAction func showSharePanel(_ sender: Any) {
        let sharedItems: [Any] = [self.reportPath!]
        sharePanel(shareItems: sharedItems)
    }
    
}
