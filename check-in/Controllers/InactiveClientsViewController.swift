//
//  InactiveClientsViewController.swift
//  check-in
//
//  Created by Joel on 6/28/16.
//  Copyright © 2016 JediMaster. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class InactiveClientsViewController: UIViewController {
    @IBOutlet var tableview: UITableView!
    
    @IBOutlet var name: UILabel!
    @IBOutlet var appointmentTime: UILabel!
    @IBOutlet var type: UILabel!
    
    var checkInEvents: Array<CheckInEvent>?
    var appDelegate: AppDelegate!
    let cellIdentifier = "inactiveCheckInCell"
    
    //------------------------------------------------------------------------------
    // MARK: Lifecycle Methods
    //------------------------------------------------------------------------------
    override func viewDidLoad() {
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(reloadData),
            name: "reloadTable",
            object: nil)

        self.tableview.tableFooterView = UIView(frame: CGRect.zero)
        fetchCompletedCheckinRecords()
    }
    
    //------------------------------------------------------------------------------
    // MARK: Private Methods
    //------------------------------------------------------------------------------
    @objc private func reloadData() {
        fetchCompletedCheckinRecords()
    }
    
    private func fetchCompletedCheckinRecords() {
        self.appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let fetch = NSFetchRequest(entityName: "CheckInEvent")
        fetch.returnsObjectsAsFaults = false
        fetch.predicate = NSPredicate(format: "status == 'completed'")
        let sd = NSSortDescriptor(key: "completedTimestamp", ascending: true, selector: nil)
        fetch.sortDescriptors = [sd]
        
        do {
            self.checkInEvents = try appDelegate.managedObjectContext.executeFetchRequest(fetch) as? Array<CheckInEvent>
        }
        catch {
            print("error: \(#file) \(#line) \(error)")
        }
        
        self.tableview.reloadData()
    }
    
    //------------------------------------------------------------------------------
    // MARK: TableView Methods
    //------------------------------------------------------------------------------
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.checkInEvents != nil ? self.checkInEvents!.count : 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let checkInEvent = self.checkInEvents![indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! InactiveClientsCell
        let df = NSDateFormatter()
        df.dateFormat = "hh:mm a"
        cell.appointmentTime.text = df.stringFromDate(checkInEvent.completedTimestamp!)
        cell.name.text = checkInEvent.name
//        let fetch = NSFetchRequest(entityName: "ServiceType")
//        fetch.returnsObjectsAsFaults = false
//        fetch.predicate = NSPredicate(format: "uniqueID == \(String(checkInEvent.serviceTypeID as! Int))")
//        do {
//            let serviceTypes = try self.appDelegate.managedObjectContext.executeFetchRequest(fetch)
//            //print (serviceTypes.count)
//        }
//        catch {
//            print("error: \(#file) \(#line) \(error)")
//        }
        return cell
    }

    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let vw = UIView()
        let titleLabel = UILabel(frame: CGRectMake(16, 6, 200, 16))
        titleLabel.text = "Clientes Completados"
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.font = UIFont(name:"HelveticaNeue-Bold", size: 18.0)
        vw.addSubview(titleLabel)
        //vw.backgroundColor = UIColor(red: 0.70, green: 0.89, blue: 1.00, alpha: 1.00)
        vw.backgroundColor = UIColor.redColor()
        return vw
    }
}