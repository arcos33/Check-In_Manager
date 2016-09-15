//
//  ServicesViewController.swift
//  check-in
//
//  Created by Joel on 8/8/16.
//  Copyright © 2016 JediMaster. All rights reserved.
//

import Foundation
import UIKit

class ServicesViewController: UIViewController, AddServiceVCDelegate {
    
    @IBOutlet var tableview: UITableView!
    
    var addServiceVC: AddServiceViewController!
    var services = Array<Service>()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let cellIdentifier = "serviceCell"
    var dataController = DataController.sharedInstance
    
    //------------------------------------------------------------------------------
    // MARK: Lifecycle Methods
    //------------------------------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataController.getServices { (services) in
            DispatchQueue.main.async(execute: {
                for item in services {
                    if item.status == "deleted" {
                        continue
                    }
                    self.services.append(item)
                }
                
                self.tableview.reloadData()
            })
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        self.addServiceVC = segue.destination as! AddServiceViewController
        self.addServiceVC.delegate = self
    }
    
    //------------------------------------------------------------------------------
    // MARK: TableView Methods
    //------------------------------------------------------------------------------
    func tableView(_ tableView: UITableView, editActionsForRowAtIndexPath indexPath: IndexPath) -> [AnyObject]? {
        let deleted = UITableViewRowAction(style: .destructive, title: "Eliminar") { (action, index) in
            let service = self.services[(indexPath as NSIndexPath).row]
            service.status = "deleted"
            self.dataController.updateServiceRecord(service.id, status: service.status)
            self.services.remove(at: (indexPath as NSIndexPath).row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }

        deleted.backgroundColor = UIColor.red
        
        return [deleted]
    }
    
    func tableView(_ tableView:UITableView!, numberOfRowsInSection section:Int)->Int{
        return self.services.count
    }
    
    
    func numberOfSectionsInTableView(_ tableView:UITableView!)->Int{
        return 1
    }
    
    func tableView(_ tableView: UITableView!, cellForRowAtIndexPath indexPath: IndexPath!) -> UITableViewCell! {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! ServiceCell
        let service = self.services[indexPath.row]
        cell.name.text = service.name
        if (service.status == "available") {
            cell.availableSwitch.setOn(true, animated: true)
        }
        else {
            cell.availableSwitch.setOn(false, animated: true)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let vw = UIView()
        let titleLabel = UILabel(frame: CGRect(x: 16, y: 6, width: 200, height: 16))
        titleLabel.text = "Servicios"
        titleLabel.textColor = UIColor.white
        titleLabel.font = UIFont(name:"HelveticaNeue-Bold", size: 18.0)
        vw.addSubview(titleLabel)
        vw.backgroundColor = UIColor(red: 0.78, green: 0.77, blue: 0.80, alpha: 1.00)

        return vw
    }
    
    //------------------------------------------------------------------------------
    // MARK: AddServiceDelegate Methods
    //------------------------------------------------------------------------------
    func didEnterServiceName(_ name: String) {
        self.dataController.postServiceRecord(name) { (services) in
            DispatchQueue.main.async(execute: {
                self.services = services
                self.tableview.reloadData()
            })
            self.addServiceVC.dismiss(animated: true, completion: nil)
        }
    }
    
    //------------------------------------------------------------------------------
    // MARK: Private Methods
    //------------------------------------------------------------------------------
    
    fileprivate func populateDataSource(_ array: [Dictionary<String, String>]) {
        for item in array {
            if item["status"] == "deleted" {
                continue
            }
            let service = Service(name: item["name"]!, id: item["id"]!, status: item["status"]!)
            self.services.append(service)        }
        DispatchQueue.main.async {
            self.tableview.reloadData()
        }
    }
    
    //------------------------------------------------------------------------------
    // MARK: Action Methods
    //------------------------------------------------------------------------------
    @IBAction func switchChanged(_ sender: AnyObject) {
        let switchSelected = sender as! UISwitch
        let cellSelected = switchSelected.superview?.superview as! UITableViewCell
        let indexPath = self.tableview.indexPath(for: cellSelected)
        let service = self.services[((indexPath as NSIndexPath?)?.row)!]
        var status: String!
        if (switchSelected.isOn) {
            status = "available"
        }
        else {
            status = "unavailable"
        }
        service.status = status
        self.dataController.updateServiceRecord(service.id, status: service.status)
    }
}
