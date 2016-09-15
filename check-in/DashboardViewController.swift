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
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        if UIDevice.current.orientation == .portraitUpsideDown {
            self.tabBarController?.selectedIndex = 1
            self.tabBarController?.tabBar.isHidden = true
        }
    }
    
    override func viewDidLoad() {
        for barItem in (self.tabBarController?.tabBar.items)! {
            if barItem.tag == 0 {
                // Default image
                barItem.image = UIImage(named: "dashboard")?.withRenderingMode(.alwaysOriginal)
                
                // By default Selected image will take tint color set in self.tabBar.tintColor
                barItem.selectedImage = UIImage(named: "Dashboard Filled")?.withRenderingMode(.alwaysOriginal)
            }
            else if barItem.tag == 2 {
                // Default image
                barItem.image = UIImage(named: "report")?.withRenderingMode(.alwaysOriginal)
                
                // By default Selected image will take tint color set in self.tabBar.tintColor
                barItem.selectedImage = UIImage(named: "Report Card Filled")?.withRenderingMode(.alwaysOriginal)
            }
            else if barItem.tag == 3 {
                // Default image
                barItem.image = UIImage(named: "Settings")?.withRenderingMode(.alwaysOriginal)
                
                // By default Selected image will take tint color set in self.tabBar.tintColor
                barItem.selectedImage = UIImage(named: "Settings Filled")?.withRenderingMode(.alwaysOriginal)
                
            }
            else if barItem.tag == 4 {
                // Default image
                barItem.image = UIImage(named: "Info-75")?.withRenderingMode(.alwaysOriginal)
                
                // By default Selected image will take tint color set in self.tabBar.tintColor
                barItem.selectedImage = UIImage(named: "Info Filled-75")?.withRenderingMode(.alwaysOriginal)
                
            }
        }
        
        populateServicesDataSource()
        populateStylistsDataSource()
        populatePaymentTypesDataSource()
            }
    
    fileprivate func populateStylistsDataSource() {
        self.dataController.getStylists { (stylists) in
            DispatchQueue.main.async(execute: {
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
    
    fileprivate func populateServicesDataSource() {
        self.dataController.getServices { (services) in
            DispatchQueue.main.async(execute: {
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
    
    fileprivate func populatePaymentTypesDataSource() {
        self.dataController.getPayments { (payments) in
            DispatchQueue.main.async(execute: {
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        case "ActiveClientDetailsSegue":
            self.activeClientDetailsTVC = segue.destination as! ActiveClientDetailsTableViewController
        case "showCheckedinClientsTable":
            self.activeClientsVC = segue.destination as! ActiveClientsViewController
            self.activeClientsVC.delegate = self
            
        default:
            print()
        }
    }
    
    func didSelectCheckinEvent(_ checkinEvent: CheckInEvent, index: NSInteger) {
        self.activeClientDetailsTVC.titleLabel.text = checkinEvent.name
        
        self.activeClientDetailsTVC.stylistNameButton.isHidden = false
        self.activeClientDetailsTVC.stylistNameButton.setTitle(checkinEvent.stylist == "" || checkinEvent.stylist == nil ? "?" : checkinEvent.stylist, for: UIControlState())
        
        self.activeClientDetailsTVC.serviceNameButton.isHidden = false
        self.activeClientDetailsTVC.serviceNameButton.setTitle(checkinEvent.service == "" || checkinEvent.service == nil ? "?" : checkinEvent.service, for: UIControlState())
        
        self.activeClientDetailsTVC.paymentTypeButton.isHidden = false
        self.activeClientDetailsTVC.paymentTypeButton.setTitle(checkinEvent.paymentType == "" || checkinEvent.paymentType == nil ? "?" : checkinEvent.paymentType, for: UIControlState())
        
        
        self.activeClientDetailsTVC.completedButton.isHidden = false
        self.activeClientDetailsTVC.DeleteButton.isHidden = false
        
        self.activeClientDetailsTVC.checkinEvent = checkinEvent
        self.activeClientDetailsTVC.selectedIndex = index
        
        self.activeClientDetailsTVC.amountChargedTextField.isHidden = false
        self.activeClientDetailsTVC.amountChargedTextField.text = checkinEvent.amountCharged
        
        self.activeClientDetailsTVC.receiptNumberTextField.isHidden = false
        self.activeClientDetailsTVC.receiptNumberTextField.text = checkinEvent.ticketNumber
    }
}
