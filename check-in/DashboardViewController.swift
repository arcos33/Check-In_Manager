//
//  DashboardViewController.swift
//  check-in
//
//  Created by Joel on 8/15/16.
//  Copyright © 2016 JediMaster. All rights reserved.
//

import Foundation
import UIKit

class DashboardViewController: UIViewController, ActiveClientsDelegate {
    var activeClientDetailsTVC: ActiveClientDetailsTableViewController!
    var activeClientsVC: ActiveClientsViewController!
    var selectedCheckinEvent: CheckInEvent!
    let dataController = DataController.sharedInstance
    
    override func viewWillAppear(animated: Bool) {
        self.tabBarController?.tabBar.hidden = false
    }
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        if UIDevice.currentDevice().orientation == .PortraitUpsideDown {
            self.tabBarController?.selectedIndex = 1
            self.tabBarController?.tabBar.hidden = true
        }
    }
    
    override func viewDidLoad() {
        for barItem in (self.tabBarController?.tabBar.items)! {
            if barItem.tag == 0 {
                // Default image
                barItem.image = UIImage(named: "dashboard")?.imageWithRenderingMode(.AlwaysOriginal)
                
                // By default Selected image will take tint color set in self.tabBar.tintColor
                barItem.selectedImage = UIImage(named: "Dashboard Filled")?.imageWithRenderingMode(.AlwaysOriginal)
            }
            else if barItem.tag == 2 {
                // Default image
                barItem.image = UIImage(named: "report")?.imageWithRenderingMode(.AlwaysOriginal)
                
                // By default Selected image will take tint color set in self.tabBar.tintColor
                barItem.selectedImage = UIImage(named: "Report Card Filled")?.imageWithRenderingMode(.AlwaysOriginal)
            }
            else if barItem.tag == 3 {
                // Default image
                barItem.image = UIImage(named: "Settings")?.imageWithRenderingMode(.AlwaysOriginal)
                
                // By default Selected image will take tint color set in self.tabBar.tintColor
                barItem.selectedImage = UIImage(named: "Settings Filled")?.imageWithRenderingMode(.AlwaysOriginal)
                
            }
            else if barItem.tag == 4 {
                // Default image
                barItem.image = UIImage(named: "Info-75")?.imageWithRenderingMode(.AlwaysOriginal)
                
                // By default Selected image will take tint color set in self.tabBar.tintColor
                barItem.selectedImage = UIImage(named: "Info Filled-75")?.imageWithRenderingMode(.AlwaysOriginal)
                
            }
        }
        
        populateServicesDataSource()
        populateStylistsDataSource()
        populatePaymentTypesDataSource()
            }
    
    private func populateStylistsDataSource() {
        self.dataController.getStylists { (stylists) in
            dispatch_async(dispatch_get_main_queue(), {
                var stylistsArray = [Stylist]()
                for item in stylists {
                    if item.status == "available" {
                        stylistsArray.append(item)
                    }
                }
                self.activeClientDetailsTVC.stylistsOffered = stylistsArray
            })
        }
    }
    
    private func populateServicesDataSource() {
        self.dataController.getServices { (services) in
            dispatch_async(dispatch_get_main_queue(), {
                var servicesArray = [Service]()
                for item in services {
                    if item.status == "available" {
                        servicesArray.append(item)
                    }
                    self.activeClientDetailsTVC.servicesOffered = servicesArray
                }
            })
        }
    }
    
    private func populatePaymentTypesDataSource() {
        self.dataController.getPayments { (payments) in
            dispatch_async(dispatch_get_main_queue(), {
                var paymentTypesArray = [Payment]()
                for item in payments {
                    if item.status == "available" {
                        paymentTypesArray.append(item)
                    }
                }
                self.activeClientDetailsTVC.paymentTypesOffered = paymentTypesArray
            })
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier! {
        case "ActiveClientDetailsSegue":
            self.activeClientDetailsTVC = segue.destinationViewController as! ActiveClientDetailsTableViewController
        case "showCheckedinClientsTable":
            self.activeClientsVC = segue.destinationViewController as! ActiveClientsViewController
            self.activeClientsVC.delegate = self
            
        default:
            print()
        }
    }
    
    func didSelectCheckinEvent(checkinEvent: CheckInEvent, index: NSInteger) {
        self.activeClientDetailsTVC.titleLabel.text = checkinEvent.name
        
        self.activeClientDetailsTVC.stylistNameButton.hidden = false
        self.activeClientDetailsTVC.stylistNameButton.setTitle(checkinEvent.stylist == "" || checkinEvent.stylist == nil ? "?" : checkinEvent.stylist, forState: .Normal)
        
        self.activeClientDetailsTVC.serviceNameButton.hidden = false
        self.activeClientDetailsTVC.serviceNameButton.setTitle(checkinEvent.service == "" || checkinEvent.service == nil ? "?" : checkinEvent.service, forState: .Normal)
        
        self.activeClientDetailsTVC.paymentTypeButton.hidden = false
        self.activeClientDetailsTVC.paymentTypeButton.setTitle(checkinEvent.paymentType == "" || checkinEvent.paymentType == nil ? "?" : checkinEvent.paymentType, forState: .Normal)
        
        
        self.activeClientDetailsTVC.completedButton.hidden = false
        self.activeClientDetailsTVC.DeleteButton.hidden = false
        
        self.activeClientDetailsTVC.checkinEvent = checkinEvent
        self.activeClientDetailsTVC.selectedIndex = index
        
        self.activeClientDetailsTVC.amountChargedTextField.hidden = false
        self.activeClientDetailsTVC.amountChargedTextField.text = checkinEvent.amountCharged
        
        self.activeClientDetailsTVC.receiptNumberTextField.hidden = false
        self.activeClientDetailsTVC.receiptNumberTextField.text = checkinEvent.ticketNumber
    }
}
