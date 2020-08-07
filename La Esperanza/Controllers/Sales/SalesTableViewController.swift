//
//  SalesTableViewController.swift
//  La Esperanza
//
//  Created by Efrain Garcia Rocha on 07/08/20.
//  Copyright © 2020 Efrain Garcia Rocha. All rights reserved.
//

import UIKit

class SalesTableViewController: UITableViewController {
    let webApi: WebApi = WebApi()
    let alerts: AlertsHelper = AlertsHelper()
    let dateFormat: DateFormatter = DateFormatter()
    var showStartDate: Bool = false
    var showEndDate: Bool = false
    var isTodaysReport: Bool = false
    var todaySalesModel: TodaySalesModel = TodaySalesModel()
    
    @IBOutlet var startDatePicker: UIDatePicker!
    @IBOutlet var endDatePicker: UIDatePicker!
    @IBOutlet var startDateLabel: UILabel!
    @IBOutlet var endDateLabel: UILabel!
    @IBOutlet var ordersCountLabel: UILabel!
    @IBOutlet var ordersDeliveryTaxLabel: UILabel!
    @IBOutlet var ordersTotalLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        dateFormat.locale = Locale(identifier: UserDefaults.standard.string(forKey: "DEFAULT_LOCALE")!)
        dateFormat.calendar = Calendar.current
        dateFormat.timeZone = TimeZone.current
        dateFormat.setLocalizedDateFormatFromTemplate("dd/MM/yyy")
        
        startDateLabel.text = dateFormat.string(from: startDatePicker.date)
        endDateLabel.text = dateFormat.string(from: endDatePicker.date)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let tabParent = self.parent as? UITabBarController {
            tabParent.navigationItem.title = NSLocalizedString("tab_sales", tableName: "messages", comment: "")
        }
        
        getTodaySales()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1 {
            if (indexPath.row == 1 && !showStartDate) || (indexPath.row == 3 && !showEndDate) { return 0 }
        }
        return super.tableView(tableView, heightForRowAt: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            if indexPath.row == 0 {
                showStartDate = !showStartDate
                showEndDate = false
            } else if indexPath.row == 2 {
                showEndDate = !showEndDate
                showStartDate = false
            }
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    func getTodaySales() {
        webApi.DoGet("orders/todaysales", onCompleteHandler: { (response, error) -> Void in
            do {
                guard error == nil else {
                    if (error as NSError?)?.code == 401 {
                        self.hideWait()
                        self.performSegue(withIdentifier: "TimeoutSegue", sender: self)
                    }
                    return
                }
                guard response != nil else { return }
                if let data = response {
                    self.hideWait()
                    self.todaySalesModel = try JSONDecoder().decode(TodaySalesModel.self, from: data)
                    
                    DispatchQueue.main.async {
                        
                        let currencyFormat = NumberFormatter()
                        currencyFormat.locale = Locale(identifier: UserDefaults.standard.string(forKey: "DEFAULT_LOCALE")!)
                        currencyFormat.allowsFloats = true
                        currencyFormat.minimumFractionDigits = 2
                        currencyFormat.maximumFractionDigits = 2
                        currencyFormat.usesGroupingSeparator = true
                        currencyFormat.numberStyle = .currencyAccounting
                        
                        self.ordersCountLabel.text = String(self.todaySalesModel.count)
                        self.ordersDeliveryTaxLabel.text = currencyFormat.string(for: self.todaySalesModel.deliveryTaxTotal)
                        self.ordersTotalLabel.text = currencyFormat.string(for: self.todaySalesModel.total)
                        
                        self.tableView.beginUpdates()
                        self.tableView.endUpdates()
                    }
                }
            } catch {
                return
            }
        })
    }
    
    @IBAction func selectedDate(_ sender: UIDatePicker) {
        if sender == startDatePicker {
            startDateLabel.text = dateFormat.string(from: sender.date)
        } else  {
            endDateLabel.text = dateFormat.string(from: sender.date)
        }
    }
    
    @IBAction func showDailyReport(_ sender: UIButton) {
        isTodaysReport = true
        self.performSegue(withIdentifier: "ShowReportSegue", sender: sender)
    }
    
    @IBAction func showRangeReport(_ sender: Any) {
        isTodaysReport = false
        self.performSegue(withIdentifier: "ShowReportSegue", sender: sender)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "yyyy-MM-dd"
        dateFormat.locale = Locale(identifier: UserDefaults.standard.string(forKey: "DEFAULT_LOCALE")!)
        dateFormat.calendar = Calendar.current
        dateFormat.timeZone = TimeZone.current
        
        let reportView = segue.destination as! SalesReportViewController
        
        if isTodaysReport {
            reportView.reportName = dateFormat.string(from: Date())
        } else {
            reportView.reportStartDate = dateFormat.string(from: startDatePicker.date)
            reportView.reportEndDate = dateFormat.string(from: endDatePicker.date)
        }
        
        reportView.isTodaysReport = isTodaysReport
    }
    
}
