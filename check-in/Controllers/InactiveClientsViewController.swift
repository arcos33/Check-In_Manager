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
    
    var checkInEvents: Array<CheckInEvent>?
    
    let cellIdentifier = "inactiveCheckInCell"
    
    override func viewDidLoad() {
        self.tableview.tableFooterView = UIView(frame: CGRect.zero)
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let fetch = NSFetchRequest(entityName: "CheckInEvent")
        fetch.returnsObjectsAsFaults = false
        fetch.predicate = NSPredicate(format: "status == 'inactive'")
        do {
            self.checkInEvents = try appDelegate.managedObjectContext.executeFetchRequest(fetch) as? Array<CheckInEvent>
            print("inactive checkInEvents = \(self.checkInEvents)")
        }
        catch {
            print("error:\(error)")
        }
    }
    
    // UITableView methods
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.checkInEvents != nil ? self.checkInEvents!.count : 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath)
    }

    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let vw = UIView()
        let titleLabel = UILabel(frame: CGRectMake(16, 8, 200, 12))
        titleLabel.text = "Inactive Check-ins"
        vw.addSubview(titleLabel)
        //vw.backgroundColor = UIColor(red: 0.70, green: 0.89, blue: 1.00, alpha: 1.00)
        vw.backgroundColor = UIColor.redColor()
        return vw
    }

}
