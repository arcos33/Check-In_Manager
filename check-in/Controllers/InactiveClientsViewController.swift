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
        NotificationCenter.default.addObserver(self, selector: #selector(fetchCheckedinClients), name: Notification.didReceiveCheckinRecordsNotification, object: nil)
        self.tableview.tableFooterView = UIView(frame: CGRect.zero)
        
        NotificationCenter.default.addObserver(self, selector: #selector(setText), name: Notification.languageChangeNotification, object: nil)
        fetchCompletedCheckinRecords()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setText()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //------------------------------------------------------------------------------
    // MARK: Private Methods
    //------------------------------------------------------------------------------
    @objc fileprivate func setText() {
        
    }
    
    @objc fileprivate func fetchCheckedinClients(_ notification: Notification) {
        var fetch: NSFetchRequest<NSFetchRequestResult>?
        if #available(iOS 10.0, *) {
            fetch = CheckInEvent.fetchRequest()
        } else {
            // Fallback on earlier versions
            fetch = NSFetchRequest(entityName: Constants.checkInEvent)
        }
        fetch?.returnsObjectsAsFaults = false
        fetch?.predicate = createPredicate()
        let sd = NSSortDescriptor(key: "completedTimestamp", ascending: true, selector: nil)
        fetch?.sortDescriptors = [sd]
        do {
            self.checkInEvents = try self.appDelegate.managedObjectContext.fetch(fetch!) as? Array<CheckInEvent>
        }
        catch {
            print("error: \(#file) \(#line) \(error)")
        }
        DispatchQueue.main.async {
            self.tableview.reloadData()
        }
    }
    
    @objc fileprivate func reloadData() {
        fetchCompletedCheckinRecords()
    }
    
    fileprivate func createPredicate() -> NSPredicate {
        var predicates: [NSPredicate]! = []
        let calendar = Calendar.current
        var components: DateComponents = (calendar as NSCalendar).components([.day, .month, .year], from: Date())
        let today = calendar.date(from: components)!
        components.day = components.day!+1
        let tomorrow = calendar.date(from: components)!
        
        let subPredicateFrom = NSPredicate(format: "checkinTimestamp >= %@", today as CVarArg)
        predicates.append(subPredicateFrom)
        
        let subPredicateTo = NSPredicate(format: "checkinTimestamp < %@", tomorrow as CVarArg)
        predicates.append(subPredicateTo)
        
        let subPredicateCompleted = NSPredicate(format: "status == 'completed'")
        predicates.append(subPredicateCompleted)
        
        return NSCompoundPredicate(type: .and, subpredicates: predicates)
    }
    
    fileprivate func fetchCompletedCheckinRecords() {
        self.appDelegate = UIApplication.shared.delegate as! AppDelegate
        let fetch = NSFetchRequest<CheckInEvent>(entityName: Constants.checkInEvent)
        fetch.predicate = createPredicate()
        fetch.returnsObjectsAsFaults = false
        let sd = NSSortDescriptor(key: "completedTimestamp", ascending: true, selector: nil)
        fetch.sortDescriptors = [sd]
        do {
            self.checkInEvents = try appDelegate.managedObjectContext.fetch(fetch)
        }
        catch {
            print("error: \(#file) \(#line) \(error)")
        }
        
        self.tableview.reloadData()
    }
    
    //------------------------------------------------------------------------------
    // MARK: TableView Methods
    //------------------------------------------------------------------------------
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.checkInEvents != nil ? self.checkInEvents!.count : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        let checkInEvent = self.checkInEvents![(indexPath as NSIndexPath).row]
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! InactiveClientsCell
        cell.type.text = "completed".localized()
        cell.appointmentTime.text = Date.getTimeInHoursAndMinutes(checkInEvent.completedTimestamp!)
        cell.name.text = checkInEvent.name
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let vw = UIView()
        let titleLabel = UILabel(frame: CGRect(x: 16, y: 6, width: 200, height: 16))
        titleLabel.text = "Clientes Completados"
        titleLabel.textColor = UIColor.white
        titleLabel.font = UIFont(name:"HelveticaNeue-Bold", size: 18.0)
        vw.addSubview(titleLabel)
        vw.backgroundColor = UIColor(red: 0.25, green: 0.67, blue: 0.00, alpha: 1.00)
        return vw
    }
}
