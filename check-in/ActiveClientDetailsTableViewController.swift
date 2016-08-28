//
//  ActiveClientDetailsTableViewController.swift
//  check-in
//
//  Created by Joel on 8/25/16.
//  Copyright © 2016 JediMaster. All rights reserved.
//

import Foundation
import UIKit

//protocol ActiveClientDetailsTVCDelegate {
//    func didUpdateCell(index: NSInteger)
//}

class ActiveClientDetailsTableViewController: UITableViewController, StylistsOfferedTableDelegate, ServicesOfferedTableDelegate, PaymentTypesOfferedTableDelegate {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var stylistNameButton: UIButton!
    @IBOutlet var serviceNameButton: UIButton!
    @IBOutlet var paymentTypeButton: UIButton!
    @IBOutlet var completedButton: UIButton!
    @IBOutlet var DeleteButton: UIButton!

    var appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var stylistTable:StylistsOfferedTableViewController?
    var servicesTable:ServicesOfferedTableViewController?
    var paymentsTable:PaymentTypesOfferedTableViewController?
    var checkinEvent: CheckInEvent?
    var serviceSelected: String?
    var stylistSelected: String?
    var paymentSelected: String?

    var stylists = [Stylist]()
    var stylistMapping = Dictionary<String, AnyObject>()
    var services = [Service]()
    var serviceMapping = Dictionary<String, AnyObject>()
    let dataController = DataController.sharedInstance
    var selectedIndex: NSInteger?
    
    override func viewDidLoad() {
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier! {
        case "stylistsOfferedTVCSegue":
            self.stylistTable = segue.destinationViewController as? StylistsOfferedTableViewController
            self.stylistTable?.delegate = self
            case "servicesOfferedTVCSegue":
                self.servicesTable = segue.destinationViewController as? ServicesOfferedTableViewController
                self.servicesTable?.delegate = self
            case "paymentsOfferedTVCSegue":
            self.paymentsTable = segue.destinationViewController as? PaymentTypesOfferedTableViewController
            self.paymentsTable?.delegate = self
        default:
            break
        }

    }
    
    //------------------------------------------------------------------------------
    // MARK: Private Methods
    //------------------------------------------------------------------------------
    

    //------------------------------------------------------------------------------
    // MARK: StylistsTableDelegate methods
    //------------------------------------------------------------------------------
    func didSelectStylist(stylist: String) {
        self.stylistNameButton.setTitle(stylist, forState: .Normal)
        self.stylistSelected = stylist
        self.checkinEvent?.stylist = stylist
        self.dataController.updateCheckInEventAtCellIndex(self.checkinEvent, index: self.selectedIndex!)
    }

    //------------------------------------------------------------------------------
    // MARK: ServicesOfferedTableDelegate methods
    //------------------------------------------------------------------------------
    func didSelectService(service: String) {
        self.serviceNameButton.setTitle(service, forState: .Normal)
        self.serviceSelected = service
        self.checkinEvent?.service = service
        self.dataController.updateCheckInEventAtCellIndex(self.checkinEvent, index: self.selectedIndex!)
    }

    //------------------------------------------------------------------------------
    // MARK: ServicesOfferedTableDelegate methods
    //------------------------------------------------------------------------------
    func didSelectPayment(payment: String) {
        self.paymentTypeButton.setTitle(payment, forState: .Normal)
        self.paymentSelected = payment
        self.checkinEvent?.paymentType = payment
        self.dataController.updateCheckInEventAtCellIndex(self.checkinEvent, index: self.selectedIndex!)
    }
    
    @IBAction func completeCheckinEvent(sender: AnyObject) {
        self.checkinEvent!.status = "completed"
        self.checkinEvent!.completedTimestamp = NSDate()
        self.saveChanges()
        self.dataController.updateCheckInEvent(self.checkinEvent!)
        NSNotificationCenter.defaultCenter().postNotificationName("ActiveClientsVCDidReceiveCompletedCheckinEvent", object: nil)
    }
    
    @IBAction func deleteCheckinEvent(sender: AnyObject) {
    }
    
    private func saveChanges() {
        do {
            try self.appDelegate.managedObjectContext.save()
        }
        catch {
            print("error: \(#file) \(#line) \(error)")
        }
    }
    
    
}
