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
    var reportStartDate: String = ""
    var reportEndDate: String = ""
    var reportName: String = ""
    var reportPath: URL?
    var isTodaysReport: Bool = true

    @IBOutlet var pdfViewer: WKWebView!
    @IBOutlet var shareButton: UIBarButtonItem!
    @IBOutlet var stopImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if isTodaysReport {
            reportName = reportStartDate.replacingOccurrences(of: "-", with: "_")
            getTodaysReport()
        } else {
            reportName = "\(reportStartDate.replacingOccurrences(of: "-", with: "_"))_\(reportEndDate.replacingOccurrences(of: "-", with: "_"))"
            getRangeReport()
        }
    }
    
    func getRangeReport() {
        self.showWait{ [self] in
            webApi.DoGet("print/report/\(reportStartDate)?enddate=\(reportEndDate)", onCompleteHandler: { response, error in
                guard error == nil else {
                    if (error as NSError?)?.code == 401 {
                        hideWait {
                            performSegue(withIdentifier: "TimeoutSegue", sender: self)
                        }
                    } else if (error as NSError?)?.code == 404 {
                        hideWait {
                            shareButton.isEnabled = false
                            stopImage.isHidden = false
                            alerts.showErrorAlert(self, message: NSLocalizedString("alert_report_notfound", tableName: "messages", comment: ""), onComplete: nil)
                        }
                    }
                    return
                }
                
                guard response!.count > 0 else { return }
                
                let pdfDocument: PDFDocument = PDFDocument(data: response!)!
                reportPath = FileManager.default.temporaryDirectory.appendingPathComponent("\(reportName).pdf")
                pdfDocument.write(to: reportPath!)
                
                hideWait {
                    DispatchQueue.main.async {
                        pdfViewer.loadFileURL(reportPath!, allowingReadAccessTo: FileManager.default.temporaryDirectory)
                    }
                }
                
            })
        }
    }
    
    func getTodaysReport() {
        self.showWait{ [self] in
            webApi.DoGet("print/sales/\(reportStartDate)", onCompleteHandler: { response, error in
                guard error == nil else {
                    if (error as NSError?)?.code == 401 {
                        hideWait {
                            performSegue(withIdentifier: "TimeoutSegue", sender: self)
                        }
                    } else if (error as NSError?)?.code == 404 {
                        hideWait {
                            shareButton.isEnabled = false
                            stopImage.isHidden = false
                            alerts.showErrorAlert(self, message: NSLocalizedString("alert_report_notfound", tableName: "messages", comment: ""), onComplete: nil)
                        }
                    }
                    return
                }
                
                guard response!.count > 0 else { return }
                
                let pdfDocument: PDFDocument = PDFDocument(data: response!)!
                reportPath = FileManager.default.temporaryDirectory.appendingPathComponent("\(reportName).pdf")
                pdfDocument.write(to: reportPath!)
                
                hideWait {
                    DispatchQueue.main.async {
                        pdfViewer.loadFileURL(reportPath!, allowingReadAccessTo: FileManager.default.temporaryDirectory)
                    }
                }
            })
        }        
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
