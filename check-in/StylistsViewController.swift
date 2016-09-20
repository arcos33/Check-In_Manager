//
//  StylistsViewController.swift
//  check-in
//
//  Created by Joel on 8/5/16.
//  Copyright © 2016 JediMaster. All rights reserved.
//

import UIKit
import CoreData


class StylistsViewController: UIViewController, AddStylistVCDelegate {
    
    @IBOutlet var tableview: UITableView!
    
    var addStylistPopOverVC: AddStylistViewController!
    var stylists = Array<Stylist>()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let cellIdentifier = "stylistCell"
    let dataController = DataController.sharedInstance
    
    //------------------------------------------------------------------------------
    // MARK: Lifecycle Methods
    //------------------------------------------------------------------------------
    override func viewDidLoad() {
        self.dataController.getStylists { (stylists) in
            DispatchQueue.main.async(execute: {
                self.stylists = stylists
                self.tableview.reloadData()
            })
        }
    }
    
    //------------------------------------------------------------------------------
    // MARK: Tableview Methods
    //------------------------------------------------------------------------------
    func tableView(_ tableView: UITableView, editActionsForRowAtIndexPath indexPath: IndexPath) -> [AnyObject]? {
        let deleted = UITableViewRowAction(style: .destructive, title: "Eliminar") { action, index in
            let stylist = self.stylists[(indexPath as NSIndexPath).row]
            stylist.status = "deleted"
            self.dataController.updateStylistRecord(stylist.id, status: stylist.status)
            self.stylists.remove(at: (indexPath as NSIndexPath).row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        deleted.backgroundColor = UIColor.red
        
        return [deleted]
    }
    
    func tableView(_ tableView:UITableView!, numberOfRowsInSection section:Int)->Int{
        return self.stylists.count
    }
    
    
    func numberOfSectionsInTableView(_ tableView:UITableView!)->Int{
        return 1
    }
    
    func tableView(_ tableView: UITableView!, cellForRowAtIndexPath indexPath: IndexPath!) -> UITableViewCell! {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! StyleListCell
        let stylist = self.stylists[indexPath.row]
        cell.name.text = stylist.name
        if (stylist.status == "available") {
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
        titleLabel.text = "Estilistas"
        titleLabel.textColor = UIColor.white
        titleLabel.font = UIFont(name:"HelveticaNeue-Bold", size: 18.0)
        vw.addSubview(titleLabel)
        vw.backgroundColor = UIColor(red: 0.78, green: 0.77, blue: 0.80, alpha: 1.00)
        return vw
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        self.addStylistPopOverVC = segue.destination as! AddStylistViewController
        self.addStylistPopOverVC.delegate = self
    }
    
    //------------------------------------------------------------------------------
    // MARK: Private Methods
    //------------------------------------------------------------------------------
    fileprivate func populateDataSource(_ array: [Dictionary<String, String>]) {
        for item in array {
            if item["status"] == "deleted" {
                continue
            }
            let stylist = Stylist(status: item["status"]!, id: item["id"]!, name: item["name"]!)
            self.stylists.append(stylist)
        }
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
        let stylist = self.stylists[((indexPath as NSIndexPath?)?.row)!]
        var status: String!
        if (switchSelected.isOn) {
            status = "available"
        }
        else {
            status = "unavailable"
        }
        stylist.status = status
        self.dataController.updateStylistRecord(stylist.id, status: stylist.status)
    }
    
    //------------------------------------------------------------------------------
    // MARK: AddStylistVCDelegate Delegate Methods
    //------------------------------------------------------------------------------\
    func didEnterStylistName(_ name: String) {
        self.addStylistPopOverVC.dismiss(animated: true, completion: nil)

        self.dataController.postStylistRecord(name) { (stylists) in
            DispatchQueue.main.async(execute: {
                self.stylists = stylists
                self.tableview.reloadData()

            })
        }
    }
}

