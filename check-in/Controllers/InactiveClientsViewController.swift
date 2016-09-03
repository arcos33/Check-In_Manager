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
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(fetchCheckedinClients), name: "DataControllerDidReceiveCheckinRecordsNotification", object: nil)

        self.tableview.tableFooterView = UIView(frame: CGRect.zero)
        fetchCompletedCheckinRecords()
    }
    
    //------------------------------------------------------------------------------
    // MARK: Private Methods
    //------------------------------------------------------------------------------
    @objc private func fetchCheckedinClients(notification: NSNotification) {
        let fetch = NSFetchRequest(entityName: "CheckInEvent")
        fetch.returnsObjectsAsFaults = false
        fetch.predicate = createPredicate()
        let sd = NSSortDescriptor(key: "completedTimestamp", ascending: true, selector: nil)
        fetch.sortDescriptors = [sd]
        do {
            self.checkInEvents = try self.appDelegate.managedObjectContext.executeFetchRequest(fetch) as? Array<CheckInEvent>
        }
        catch {
            print("error: \(#file) \(#line) \(error)")
        }
        dispatch_async(dispatch_get_main_queue()) {
            self.tableview.reloadData()
        }
    }
    
    @objc private func reloadData() {
        fetchCompletedCheckinRecords()
    }
    
    private func createPredicate() -> NSPredicate {
        var predicates: [NSPredicate]! = []
        let calendar = NSCalendar.currentCalendar()
        let components: NSDateComponents = calendar.components([.Day, .Month, .Year], fromDate: NSDate())
        let today = calendar.dateFromComponents(components)!
        components.day = components.day+1
        let tomorrow = calendar.dateFromComponents(components)!
        
        let subPredicateFrom = NSPredicate(format: "checkinTimestamp >= %@", today)
        predicates.append(subPredicateFrom)
        
        let subPredicateTo = NSPredicate(format: "checkinTimestamp < %@", tomorrow)
        predicates.append(subPredicateTo)
        
        let subPredicateCompleted = NSPredicate(format: "status == 'completed'")
        predicates.append(subPredicateCompleted)
        
        return NSCompoundPredicate(type: .AndPredicateType, subpredicates: predicates)
    }
    
    private func fetchCompletedCheckinRecords() {
        self.appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

        let fetch = NSFetchRequest(entityName: "CheckInEvent")
        fetch.predicate = createPredicate()
        fetch.returnsObjectsAsFaults = false
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

        cell.appointmentTime.text = NSDate.getTimeInHoursAndMinutes(checkInEvent.completedTimestamp!)
        cell.name.text = checkInEvent.name
        return cell
    }

    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let vw = UIView()
        let titleLabel = UILabel(frame: CGRectMake(16, 6, 200, 16))
        titleLabel.text = "Clientes Completados"
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.font = UIFont(name:"HelveticaNeue-Bold", size: 18.0)
        vw.addSubview(titleLabel)
        vw.backgroundColor = UIColor(red: 0.25, green: 0.67, blue: 0.00, alpha: 1.00)
        return vw
    }
}