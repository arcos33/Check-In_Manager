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
import Localize_Swift

protocol ActiveClientsDelegate {
    func didSelectCheckinEvent(_ checkinEvent: CheckInEvent, index: NSInteger)
}

class ActiveClientsViewController: UIViewController {
    
    @IBOutlet var tableview: UITableView!
    @IBOutlet var name: UILabel!
    @IBOutlet var checkInTime: UILabel!
    @IBOutlet var type: UILabel!
    
    var headerView: ActiveClientsHeaderView!
    
    var delegate: ActiveClientsDelegate?
    
    var checkInEvents: Array<CheckInEvent>?
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: UIControl.Event.valueChanged)
        
        return refreshControl
    }()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let cellIdentifier = "activeCheckInCell"
    let dataController = DataController.sharedInstance
    var cellSelected: Int?
    
    //------------------------------------------------------------------------------
    // MARK: Lifecycle Methods
    //------------------------------------------------------------------------------
    override func viewDidLoad() {
        self.tableview.tableFooterView = UIView(frame: CGRect.zero)
        self.tableview.addSubview(self.refreshControl)
        NotificationCenter.default.addObserver(self, selector: #selector(fetchCheckedinClients), name: Notification.didReceiveCheckinRecordsNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(setText), name: Notification.languageChangeNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.dataController.getCheckinRecords()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    
    //------------------------------------------------------------------------------
    // MARK: Private Methods
    //------------------------------------------------------------------------------
    @objc fileprivate func setText() {
        self.headerView.clientLabel.text = "Client".localized()
        print(self.headerView.clientLabel.text)
        self.headerView.serviceLabel.text = "Service".localized()
        self.headerView.stylistLabel.text = IndustryHelper.getName()
        self.headerView.waitTimeLabel.text = "Wait".localized()
    }
    
    @objc fileprivate func getCheckinEvents(_ notification: Notification) {
        self.dataController.getCheckinRecords()
        DispatchQueue.main.async {
            let index = notification.object as! NSInteger
            let indexPath = IndexPath(row:index, section: 0)
            self.tableview.selectRow(at: indexPath, animated: true, scrollPosition: .none)

//            self.selectRowAndReloadTable({
//                self.tableview.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: .None)
//            })
        }
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
        
        let subPredicateCompleted = NSPredicate(format: "status == 'checkedin'")
        predicates.append(subPredicateCompleted)
        
        return NSCompoundPredicate(type: .and, subpredicates: predicates)
    }
    
    fileprivate func selectRowAndReloadTable(_ completion: (() -> Void)) {
        self.tableview.reloadData()
        completion()
    }
    
    @objc fileprivate func handleRefresh(_ refreshControl: UIRefreshControl) {
        self.tableview.reloadData()
        self.refreshControl.endRefreshing()
    }
    
    @objc fileprivate func didReceiveCompletedCheckinEvent() {
        self.dataController.getCheckinRecords()
    }
    
    fileprivate func saveChanges() {
        do {
            try self.appDelegate.managedObjectContext.save()
        }
        catch {
            print("error: \(#file) \(#line) \(error)")
        }
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
        let sd = NSSortDescriptor(key: "checkinTimestamp", ascending: true, selector: nil)
        fetch?.sortDescriptors = [sd]
        do {
            self.checkInEvents = try self.appDelegate.managedObjectContext.fetch(fetch!) as? Array<CheckInEvent>
            print()
        }
        catch {
            print("error: \(#file) \(#line) \(error)")
        }
        DispatchQueue.main.async {
            self.tableview.reloadData()
            if let index = self.cellSelected {
                let indexPath = IndexPath(row: index, section: 0)
                self.tableview.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            }
            self.setText()
        }
    }
    
    fileprivate func createPdfFromView(_ aView: UIView, saveToDocumentsWithFileName fileName: String)
    {
        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, aView.bounds, nil)
        UIGraphicsBeginPDFPage()
        
        guard let pdfContext = UIGraphicsGetCurrentContext() else { return }
        
        aView.layer.render(in: pdfContext)
        UIGraphicsEndPDFContext()
        
        if let documentDirectories = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first {
            let documentsFileName = documentDirectories + "/" + fileName
            debugPrint(documentsFileName)
            pdfData.write(toFile: documentsFileName, atomically: true)
        }
    }
    
    //------------------------------------------------------------------------------
    // MARK: TableView Methods
    //------------------------------------------------------------------------------
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.checkInEvents != nil ? self.checkInEvents!.count : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        let checkinEvent = self.checkInEvents![(indexPath as NSIndexPath).row]
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! ActiveClientsCell
        cell.name.text = checkinEvent.name
        cell.appointmentTime.text = Date.getTimeInHoursAndMinutes(checkinEvent.checkinTimestamp!)
        
        cell.serviceLabel.text = checkinEvent.service
        cell.stylistLabel.text = checkinEvent.stylist
        let aView = UIView.init(frame: cell.frame)
        aView.backgroundColor = UIColor(red: 0.00, green: 122.0/255.0, blue: 1.0, alpha: 1.00)
        cell.selectedBackgroundView = aView
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        self.headerView = tableView.dequeueReusableCell(withIdentifier: "activeClientsHeaderView") as! ActiveClientsHeaderView
        
        setText()
        
        return headerView
    }
        
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        self.delegate?.didSelectCheckinEvent(self.checkInEvents![(indexPath as NSIndexPath).row], index: (indexPath as NSIndexPath).row)
        self.cellSelected = (indexPath as NSIndexPath).row
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
}
