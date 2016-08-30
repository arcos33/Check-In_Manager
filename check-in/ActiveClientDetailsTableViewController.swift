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
    @IBOutlet var amountChargedTextField: UITextField!
    @IBOutlet var receiptNumberTextField: UITextField!
    
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
        self.checkinEvent?.updateDate = NSDate.getCurrentLocalDate()
        do {
            try appDelegate.managedObjectContext.save()
        }
        catch {
            print("Class:\(#file)\n Line:\(#line)\n Error:\(error)")
        }
        self.dataController.updateCheckInEventAtCellIndex(self.checkinEvent, index: self.selectedIndex!)
    }

    //------------------------------------------------------------------------------
    // MARK: ServicesOfferedTableDelegate methods
    //------------------------------------------------------------------------------
    func didSelectService(service: String) {
        self.serviceNameButton.setTitle(service, forState: .Normal)
        self.serviceSelected = service
        self.checkinEvent?.service = service
        self.checkinEvent?.updateDate = NSDate.getCurrentLocalDate()
        do {
            try appDelegate.managedObjectContext.save()
        }
        catch {
            print("Class:\(#file)\n Line:\(#line)\n Error:\(error)")
        }
        self.dataController.updateCheckInEventAtCellIndex(self.checkinEvent, index: self.selectedIndex!)
    }

    //------------------------------------------------------------------------------
    // MARK: ServicesOfferedTableDelegate methods
    //------------------------------------------------------------------------------
    func didSelectPayment(payment: String) {
        self.paymentTypeButton.setTitle(payment, forState: .Normal)
        self.paymentSelected = payment
        self.checkinEvent?.paymentType = payment
        self.checkinEvent?.updateDate = NSDate.getCurrentLocalDate()
        do {
            try appDelegate.managedObjectContext.save()
        }
        catch {
            print("Class:\(#file)\n Line:\(#line)\n Error:\(error)")
        }
        self.dataController.updateCheckInEventAtCellIndex(self.checkinEvent, index: self.selectedIndex!)
    }
    
    @IBAction func completeCheckinEvent(sender: AnyObject) {
        self.checkinEvent!.amountCharged = self.amountChargedTextField.text
        self.checkinEvent!.ticketNumber = self.receiptNumberTextField.text
        self.checkinEvent!.status = "completed"
        self.checkinEvent!.updateDate = NSDate.getCurrentLocalDate()
        self.checkinEvent!.completedTimestamp = NSDate.getCurrentLocalDate()
        self.saveChanges()
    }
    
    @IBAction func deleteCheckinEvent(sender: AnyObject) {
        self.checkinEvent!.status = "deleted"
        self.checkinEvent!.updateDate = NSDate.getCurrentLocalDate()
        self.saveChanges()
        
    }
    
    private func saveChanges() {
        do {
            try self.appDelegate.managedObjectContext.save()
            self.dataController.updateCheckInEventAtCellIndex(self.checkinEvent, index: self.selectedIndex!)
            resetFields()
            
        }
        catch {
            print("error: \(#file) \(#line) \(error)")
        }
    }
    
    private func resetFields() {
        self.titleLabel.text = ""
        self.serviceNameButton.setTitle("", forState: .Normal)
        self.serviceNameButton.hidden = true
        self.stylistNameButton.setTitle("", forState: .Normal)
        self.stylistNameButton.hidden = true
        self.paymentTypeButton.setTitle("", forState: .Normal)
        self.paymentTypeButton.hidden = true
        self.amountChargedTextField.text = ""
        self.amountChargedTextField.hidden = true
        self.receiptNumberTextField.text = ""
        self.receiptNumberTextField.hidden = true
        
    }
    
    
}
