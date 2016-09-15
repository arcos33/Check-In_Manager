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
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        if UIDevice.current.orientation == .portraitUpsideDown {
            self.tabBarController?.selectedIndex = 1
            self.tabBarController?.tabBar.isHidden = true
        }
    }
    
    @IBAction func goToIcon8Webpage(_ sender: UIButton) {
        UIApplication.shared.open(URL(string:"http:www.icons8.com")!, options: [:], completionHandler: nil)
    }
}
