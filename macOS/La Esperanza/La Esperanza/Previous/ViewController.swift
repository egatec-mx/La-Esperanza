//
//  ViewController.swift
//  esperanza
//
//  Created by Efrain Garcia Rocha on 02/05/20.
//  Copyright © 2020 Efrain Garcia Rocha. All rights reserved.
//

import UIKit
import WebKit
import PDFKit

class ViewController: UIViewController, WKScriptMessageHandler {
    @objc var WebView: WKWebView!
    let openPDF: String = "openPDF"
    let baseUrl: String = ""
    let hideModalScript: String = "$('#waitModal').modal('hide');"
    
    override func viewDidLoad() {
        WebView = WKWebView()
        WebView.configuration.dataDetectorTypes = .all
        WebView.configuration.userContentController.add(self, name: openPDF)
        WebView.addObserver(self, forKeyPath: #keyPath(title), options: .new, context: nil)
        WebView.load(URLRequest(url: URL(string: baseUrl)!))
        view = WebView
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "title" {
            if let title = WebView.title {
                if title.contains("Inicio") {
                    let arg = UserDefaults.standard.string(forKey: "Token") ?? ""
                    let script = "setTimeout(function(){$.registerAppleDevice('\(arg)');},1000);"
                    WebView.evaluateJavaScript(script, completionHandler: nil)
                }
            }
        }
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == openPDF {
            let pdfRoute: String = message.body as! String
            let pdfUrl: URL = URL(string: "\(baseUrl)\(pdfRoute)")!
            var pdfRequest = URLRequest(url: pdfUrl)
            pdfRequest.setValue(UserDefaults.standard.string(forKey: "Token"), forHTTPHeaderField: "Device")
            let pdfTask = URLSession.shared.dataTask(with: pdfRequest) { (data, response, error) -> Void in
                guard data!.count > 0 else {
                    let alert = UIAlertController(title: "La Esperanza dice ...", message: "No está autorizado para ver, guardar o compartir los archivos", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: nil))
                    DispatchQueue.main.async {
                        self.present(alert, animated: true, completion: nil)
                        self.WebView.evaluateJavaScript(self.hideModalScript, completionHandler: nil)
                    }
                    return
                }
                let pdfDocument: PDFDocument = PDFDocument(data: data!)!
                let pdfName: String = String(pdfRoute.suffix(from: pdfRoute.index(pdfRoute.lastIndex(of: "/")!, offsetBy: 1))).leftPadding(toLength: 6, withPad: "0")
                let pdfPath = FileManager.default.temporaryDirectory.appendingPathComponent("\(pdfName).pdf")
                pdfDocument.write(to: pdfPath)
                let sharedItems: [Any] = [pdfPath]
                DispatchQueue.main.async {
                    self.showSharePanel(shareItems: sharedItems)
                }
            }
            pdfTask.resume()
        }
    }
    
    func showSharePanel(shareItems: [Any]){
        let shareActivity: UIActivityViewController = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
        shareActivity.popoverPresentationController?.sourceView = view
        present(shareActivity, animated: true, completion: { () -> Void in
            self.WebView.evaluateJavaScript(self.hideModalScript, completionHandler: nil)
        })
    }
}
