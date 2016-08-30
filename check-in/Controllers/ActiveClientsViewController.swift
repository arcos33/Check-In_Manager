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

protocol ActiveClientsDelegate {
    func didSelectCheckinEvent(checkinEvent: CheckInEvent, index: NSInteger)
}

class ActiveClientsViewController: UIViewController {
    
    @IBOutlet var tableview: UITableView!
    @IBOutlet var name: UILabel!
    @IBOutlet var checkInTime: UILabel!
    @IBOutlet var type: UILabel!
    
    var delegate: ActiveClientsDelegate?
    
    var checkInEvents: Array<CheckInEvent>?
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), forControlEvents: UIControlEvents.ValueChanged)
        
        return refreshControl
    }()
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let cellIdentifier = "activeCheckInCell"
    let dataController = DataController.sharedInstance
    
    //------------------------------------------------------------------------------
    // MARK: Lifecycle Methods
    //------------------------------------------------------------------------------
    override func viewDidLoad() {
        self.tableview.tableFooterView = UIView(frame: CGRect.zero)
        self.tableview.addSubview(self.refreshControl)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(fetchCheckedinClients), name: "DataControllerDidReceiveCheckinRecordsNotification", object: nil)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(didReceiveCompletedCheckinEvent), name: "ActiveClientsVCDidReceiveCompletedCheckinEvent", object: nil)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        reloadData()
    }
    //------------------------------------------------------------------------------
    // MARK: Private Methods
    //------------------------------------------------------------------------------
    @objc private func getCheckinEvents(notification: NSNotification) {
        self.dataController.getCheckinRecords()
        dispatch_async(dispatch_get_main_queue()) {
            let index = notification.object as! NSInteger
            let indexPath = NSIndexPath(forRow:index, inSection: 0)
            self.tableview.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: .None)

//            self.selectRowAndReloadTable({
//                self.tableview.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: .None)
//            })
        }
    }
    
    private func selectRowAndReloadTable(completion: (() -> Void)) {
        self.tableview.reloadData()
        completion()
    }
    
    @objc private func handleRefresh(refreshControl: UIRefreshControl) {
        self.tableview.reloadData()
        self.refreshControl.endRefreshing()
    }
    
    private func reloadData() {
        self.dataController.getCheckinRecords()
    }
    
    @objc private func didReceiveCompletedCheckinEvent() {
        self.dataController.getCheckinRecords()
    }
    
    private func saveChanges() {
        do {
            try self.appDelegate.managedObjectContext.save()
        }
        catch {
            print("error: \(#file) \(#line) \(error)")
        }
    }
    
    @objc private func fetchCheckedinClients(notification: NSNotification) {
        
        if let index = notification.object as? NSInteger {
            finishFetching(index, indexIsPassed: true)
        }
        else {
            finishFetching(nil, indexIsPassed: false)
        }
    }
    
    private func finishFetching(index: NSInteger?, indexIsPassed: Bool) {
        let fetch = NSFetchRequest(entityName: "CheckInEvent")
        fetch.returnsObjectsAsFaults = false
        fetch.predicate = NSPredicate(format: "status == 'checkedin'")
        let sd = NSSortDescriptor(key: "checkinTimestamp", ascending: true, selector: nil)
        fetch.sortDescriptors = [sd]
        do {
            self.checkInEvents = try self.appDelegate.managedObjectContext.executeFetchRequest(fetch) as? Array<CheckInEvent>
        }
        catch {
            print("error: \(#file) \(#line) \(error)")
        }
        dispatch_async(dispatch_get_main_queue()) {
            self.tableview.reloadData()
            if indexIsPassed == true {
                let indexPath = NSIndexPath(forRow: index!, inSection: 0)
                self.tableview.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: .None)
            }
        }
    }
    
    private func createPdfFromView(aView: UIView, saveToDocumentsWithFileName fileName: String)
    {
        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, aView.bounds, nil)
        UIGraphicsBeginPDFPage()
        
        guard let pdfContext = UIGraphicsGetCurrentContext() else { return }
        
        aView.layer.renderInContext(pdfContext)
        UIGraphicsEndPDFContext()
        
        if let documentDirectories = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first {
            let documentsFileName = documentDirectories + "/" + fileName
            debugPrint(documentsFileName)
            pdfData.writeToFile(documentsFileName, atomically: true)
        }
    }
    
    //------------------------------------------------------------------------------
    // MARK: TableView Methods
    //------------------------------------------------------------------------------
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.checkInEvents != nil ? self.checkInEvents!.count : 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let checkinEvent = self.checkInEvents![indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! ActiveClientsCell
        cell.name.text = checkinEvent.name
        cell.appointmentTime.text = NSDate.getTimeInHoursAndMinutes(checkinEvent.checkinTimestamp!)
        
        cell.serviceLabel.text = checkinEvent.service
        cell.stylistLabel.text = checkinEvent.stylist
        let aView = UIView.init(frame: cell.frame)
        aView.backgroundColor = UIColor(red: 0.00, green: 122.0/255.0, blue: 1.0, alpha: 1.00)
        cell.selectedBackgroundView = aView
        
        return cell
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let vw = UIView()
        let titleLabel = UILabel(frame: CGRectMake(16, 6, 750, 16))
        titleLabel.text = "Cliente         Servicio        Estilista           Espera"
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.font = UIFont(name:"HelveticaNeue-Bold", size: 18.0)
        vw.addSubview(titleLabel)
        vw.backgroundColor = UIColor.lightGrayColor()
        //vw.backgroundColor = UIColor(red: 0.00, green: 0.50, blue: 0.00, alpha: 1.00)
        return vw
    }
        
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.delegate?.didSelectCheckinEvent(self.checkInEvents![indexPath.row], index: indexPath.row)
    }
    
}