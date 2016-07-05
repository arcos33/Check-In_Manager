//
//  ActiveClientsViewController.swift
//  check-in
//
//  Created by JediMaster on 6/26/16.
//  Copyright © 2016 JediMaster. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class ActiveClientsViewController: UIViewController {
    
    @IBOutlet var tableview: UITableView!
    
    var checkInEvents: Array<CheckInEvent>?
    
    let cellIdentifier = "activeCheckInCell"
    
    override func viewDidLoad() {
        self.tableview.tableFooterView = UIView(frame: CGRect.zero)
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let fetch = NSFetchRequest(entityName: "CheckInEvent")
        fetch.returnsObjectsAsFaults = false
        fetch.predicate = NSPredicate(format: "status == 'active'")
        do {
            self.checkInEvents = try appDelegate.managedObjectContext.executeFetchRequest(fetch) as? Array<CheckInEvent>
            print("active checkInEvents = \(self.checkInEvents)")
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
        let titleLabel = UILabel(frame: CGRectMake(16, 6, 200, 16))
        titleLabel.text = "Active Check-ins"
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.font = UIFont(name:"HelveticaNeue-Bold", size: 18.0)
        vw.addSubview(titleLabel)
        //vw.backgroundColor = UIColor(red: 0.70, green: 0.89, blue: 1.00, alpha: 1.00)
        vw.backgroundColor = UIColor.greenColor()
        return vw
    }
}