//
//  ActiveClientDetailsTableViewController.swift
//  check-in
//
//  Created by Joel on 8/25/16.
//  Copyright © 2016 JediMaster. All rights reserved.
//

import Foundation
import UIKit

class ActiveClientDetailsTableViewController: UITableViewController, StylistsOfferedTableDelegate, ServicesOfferedTableDelegate, PaymentTypesOfferedTableDelegate {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var stylistNameButton: UIButton!
    @IBOutlet var serviceNameButton: UIButton!
    @IBOutlet var paymentTypeButton: UIButton!
    @IBOutlet var amountChargedTextField: UITextField!
    @IBOutlet var receiptNumberTextField: UITextField!
    
    @IBOutlet var serviceLabel: UILabel!
    @IBOutlet var stylistLabel: UILabel!
    @IBOutlet var paymentTypeLabel: UILabel!
    @IBOutlet var paymentAmountLabel: UILabel!
    @IBOutlet var receiptNumberLabel: UILabel!
    @IBOutlet var completedButton: UIButton!
    @IBOutlet var DeleteButton: UIButton!
    
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    var stylistTable:StylistsOfferedTableViewController?
    var servicesTable:ServicesOfferedTableViewController?
    var paymentsTable:PaymentTypesOfferedTableViewController?
    var checkinEvent: CheckInEvent?
    var serviceSelected: String?
    var stylistSelected: String?
    var paymentSelected: String?

    var stylistsOffered = [Stylist]()
    var stylistMapping = Dictionary<String, AnyObject>()
    var servicesOffered = [Service]()
    var serviceMapping = Dictionary<String, AnyObject>()
    var paymentTypesOffered = [Payment]()
    let dataController = DataController.sharedInstance
    var selectedIndex: NSInteger?
    
    override func viewDidLoad() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateServicesArray), name: Notification.serviceRecordsChangedNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateStylistsArray), name: Notification.stylistRecordsChangedNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(setText), name: Notification.languageChangeNotification, object: nil)

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        case "stylistsOfferedTVCSegue":
            self.stylistTable = segue.destination as? StylistsOfferedTableViewController
            self.stylistTable?.stylistsOffered = self.stylistsOffered
            self.stylistTable?.delegate = self
            case "servicesOfferedTVCSegue":
                self.servicesTable = segue.destination as? ServicesOfferedTableViewController
                self.servicesTable?.servicesOffered = self.servicesOffered
                self.servicesTable?.delegate = self
            case "paymentsOfferedTVCSegue":
            self.paymentsTable = segue.destination as? PaymentTypesOfferedTableViewController
            self.paymentsTable?.paymentTypesOffered = self.paymentTypesOffered
            self.paymentsTable?.delegate = self
        default:
            break
        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        setText()
        self.tableView.reloadData()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //------------------------------------------------------------------------------
    // MARK: Private Methods
    //------------------------------------------------------------------------------

    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int)
    {
        let header:UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        switch section {
        case 0:
            header.textLabel?.text = "General".localized()
        case 1:
            header.textLabel?.text = "Billing".localized()
        default:
            break
        }
    }
    
    @objc fileprivate func setText() {
        self.serviceLabel.text = "Service".localized()
        self.stylistLabel.text = IndustryHelper.getName()
        self.paymentTypeLabel.text = "Payment Type".localized()
        self.paymentAmountLabel.text = "Amount".localized()
        self.receiptNumberLabel.text = "Receipt Number".localized()
        self.completedButton.setTitle("Complete".localized(), for: .normal)
        self.DeleteButton.setTitle("Delete".localized(), for: .normal)
    }
    
    @objc fileprivate func updateServicesArray() {
        //get available ServicesOffered()
        self.dataController.getServices { (services) in
            DispatchQueue.main.async(execute: {
                self.servicesOffered = []
                var servicesArray = [Service]()
                for item in services {
                    if item.status == "available" {
                        servicesArray.append(item)
                    }
                    self.servicesOffered = servicesArray
                }
            })
        }
    }
    
    @objc fileprivate func updateStylistsArray() {
        self.dataController.getStylists { (stylists) in
            DispatchQueue.main.async(execute: {
                var stylistsArray = [Stylist]()
                for item in stylists {
                    if item.status == "available" {
                        stylistsArray.append(item)
                    }
                }
                self.stylistsOffered = stylistsArray
            })
        }

    }

    //------------------------------------------------------------------------------
    // MARK: StylistsTableDelegate methods
    //------------------------------------------------------------------------------
    func didSelectStylist(_ stylist: String) {
        self.stylistNameButton.setTitle(stylist, for: UIControlState())
        self.stylistSelected = stylist
        self.checkinEvent?.stylist = stylist
        self.checkinEvent?.updateDate = Date.getCurrentLocalDate()
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
    func didSelectService(_ service: String) {
        self.serviceNameButton.setTitle(service, for: UIControlState())
        self.serviceSelected = service
        self.checkinEvent?.service = service
        self.checkinEvent?.updateDate = Date.getCurrentLocalDate()
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
    func didSelectPayment(_ payment: String) {
        self.paymentTypeButton.setTitle(payment, for: UIControlState())
        self.paymentSelected = payment
        self.checkinEvent?.paymentType = payment
        self.checkinEvent?.updateDate = Date.getCurrentLocalDate()
        do {
            try appDelegate.managedObjectContext.save()
        }
        catch {
            print("Class:\(#file)\n Line:\(#line)\n Error:\(error)")
        }
        self.dataController.updateCheckInEventAtCellIndex(self.checkinEvent, index: self.selectedIndex!)
    }
    
    //------------------------------------------------------------------------------
    // MARK: Action Methods
    //------------------------------------------------------------------------------
    
    @IBAction func completeCheckinEvent(_ sender: AnyObject) {
        self.checkinEvent!.amountCharged = self.amountChargedTextField.text
        self.checkinEvent!.ticketNumber = self.receiptNumberTextField.text
        self.checkinEvent!.status = "completed"
        self.checkinEvent!.updateDate = Date.getCurrentLocalDate()
        self.checkinEvent!.completedTimestamp = Date.getCurrentLocalDate()
        self.saveChanges()
        
        self.dataController.updateCheckInEventAtCellIndex(self.checkinEvent, index: self.selectedIndex!)
        resetFields()
    }
    
    @IBAction func deleteCheckinEvent(_ sender: AnyObject) {
        self.checkinEvent!.status = "deleted"
        self.checkinEvent!.updateDate = Date.getCurrentLocalDate()
        self.saveChanges()
        self.dataController.updateCheckInEventAtCellIndex(self.checkinEvent, index: self.selectedIndex!)
        resetFields()
    }
    
    fileprivate func saveChanges() {
        do {
            try self.appDelegate.managedObjectContext.save()
            
        }
        catch {
            print("error: \(#file) \(#line) \(error)")
        }
    }
    
    fileprivate func resetFields() {
        self.titleLabel.text = ""
        self.serviceNameButton.setTitle("", for: UIControlState())
        self.serviceNameButton.isHidden = true
        self.stylistNameButton.setTitle("", for: UIControlState())
        self.stylistNameButton.isHidden = true
        self.paymentTypeButton.setTitle("", for: UIControlState())
        self.paymentTypeButton.isHidden = true
        self.amountChargedTextField.text = ""
        self.amountChargedTextField.isHidden = true
        self.receiptNumberTextField.text = ""
        self.receiptNumberTextField.isHidden = true
        self.completedButton.isHidden = true
        self.DeleteButton.isHidden = true
        self.receiptNumberTextField.resignFirstResponder()
        self.amountChargedTextField.resignFirstResponder()
    }
    
    
}
