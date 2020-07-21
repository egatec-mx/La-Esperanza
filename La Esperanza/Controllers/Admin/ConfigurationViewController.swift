//
//  AdminTableViewController.swift
//  La Esperanza
//
//  Created by Efrain Garcia Rocha on 09/07/20.
//  Copyright © 2020 Efrain Garcia Rocha. All rights reserved.
//

import UIKit

class ConfigurationViewController: UITableViewController {
    var webApi: WebApi = WebApi()
    var profile: ProfileModel = ProfileModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        getProfile()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let tabParent = self.parent as? UITabBarController {
            tabParent.navigationItem.title = NSLocalizedString("tab_admin", tableName: "messages" ,comment: "")
        }
        
        self.navigationController?.setToolbarHidden(true, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            cell.textLabel?.text = profile.name
            cell.detailTextLabel?.text = profile.role
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch  indexPath.section {
        case 0:
            return
        case 1:
            switch indexPath.row {
            case 0:
                performSegue(withIdentifier: "ProductSegue", sender: self)
            default:
                return
            }
        default:
            return
        }
    }
    
    func getProfile() {
        self.showWait()
        webApi.DoGet("account/profile", onCompleteHandler: { (response, error) -> Void in
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
                    self.profile = try JSONDecoder().decode(ProfileModel.self, from: data)
                    self.tableView.reloadData()
                }
            } catch {
                return
            }
        })
    }

}
