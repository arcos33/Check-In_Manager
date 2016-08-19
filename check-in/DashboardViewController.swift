//
//  DashboardViewController.swift
//  check-in
//
//  Created by Joel on 8/15/16.
//  Copyright © 2016 JediMaster. All rights reserved.
//

import Foundation
import UIKit

class DashboardViewController: UIViewController {
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
        }
    }

}
