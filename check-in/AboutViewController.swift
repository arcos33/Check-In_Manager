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
    
    
    @IBAction func goToIcon8Webpage(sender: UIButton) {
        UIApplication.sharedApplication().openURL(NSURL(string:"http:www.icons8.com")!)
    }
}