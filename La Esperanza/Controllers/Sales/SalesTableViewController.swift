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
    let dateFormat = DateFormatter()
    var showStartDate = false
    var showEndDate = false
    
    @IBOutlet var startDatePicker: UIDatePicker!
    @IBOutlet var endDatePicker: UIDatePicker!
    @IBOutlet var startDateLabel: UILabel!
    @IBOutlet var endDateLabel: UILabel!
    
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
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.row == 1 && !showStartDate) || (indexPath.row == 3 && !showEndDate) { return 0 }
        return super.tableView(tableView, heightForRowAt: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            showStartDate = !showStartDate
            showEndDate = false
        } else if indexPath.row == 2 {
            showEndDate = !showEndDate
            showStartDate = false
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    @IBAction func selectedDate(_ sender: UIDatePicker) {
        if sender == startDatePicker {
            startDateLabel.text = dateFormat.string(from: sender.date)
        } else  {
            endDateLabel.text = dateFormat.string(from: sender.date)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "yyyy-MM-dd"
        dateFormat.locale = Locale(identifier: UserDefaults.standard.string(forKey: "DEFAULT_LOCALE")!)
        dateFormat.calendar = Calendar.current
        dateFormat.timeZone = TimeZone.current
        
        let reportView = segue.destination as! SalesReportViewController
        reportView.reportDate = dateFormat.string(from: startDatePicker.date)
    }
    
}
