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
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier! {
        case "ActiveClientDetailsSegue":
            self.activeClientDetailsTVC = segue.destinationViewController as! ActiveClientDetailsTableViewController
            print()
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
        self.activeClientDetailsTVC.stylistNameButton.setTitle(checkinEvent.stylist == "" ? "Nombre" : checkinEvent.stylist, forState: .Normal)
        
        self.activeClientDetailsTVC.serviceNameButton.hidden = false
        self.activeClientDetailsTVC.serviceNameButton.setTitle(checkinEvent.service == "" ? "Nombre" : checkinEvent.service, forState: .Normal)
        
        self.activeClientDetailsTVC.paymentTypeButton.hidden = false
        self.activeClientDetailsTVC.paymentTypeButton.setTitle(checkinEvent.paymentType == nil ? "Nombre" : checkinEvent.paymentType, forState: .Normal)
        
       
        self.activeClientDetailsTVC.completedButton.hidden = false
        self.activeClientDetailsTVC.DeleteButton.hidden = false
        
        self.activeClientDetailsTVC.checkinEvent = checkinEvent
        self.activeClientDetailsTVC.selectedIndex = index
    }
}
