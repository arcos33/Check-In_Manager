//
//  AboutViewController.swift
//  check-in
//
//  Created by Joel on 9/2/16.
//  Copyright © 2016 JediMaster. All rights reserved.
//

import Foundation
import UIKit

class AboutViewController: UIViewController {
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        if UIDevice.currentDevice().orientation == .PortraitUpsideDown {
            self.tabBarController?.selectedIndex = 1
            self.tabBarController?.tabBar.hidden = true
        }
    }
    
    @IBAction func goToIcon8Webpage(sender: UIButton) {
        UIApplication.sharedApplication().openURL(NSURL(string:"http:www.icons8.com")!)
    }
}