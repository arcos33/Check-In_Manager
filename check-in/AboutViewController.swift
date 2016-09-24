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
    
    @IBOutlet var mainTitleLabel: UILabel!
    @IBOutlet var questionsLabel: UILabel!
 
    override func viewDidLoad() {
        NotificationCenter.default.addObserver(self, selector: #selector(setText), name: Notification.languageChangeNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setText()
    }
    
    @objc fileprivate func setText() {
        self.mainTitleLabel.text = "About".localized()
        self.questionsLabel.text = "Questions/Comments?".localized()
    }
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        if UIDevice.current.orientation == .portraitUpsideDown {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "checkInViewController") as! CheckInViewController
            vc.tabBarControllerRef = self.tabBarController
            vc.tabSelected = TabBarSection.AboutTab.rawValue
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    @IBAction func goToIcon8Webpage(_ sender: UIButton) {
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(URL(string:"http:www.icons8.com")!, options: [:], completionHandler: nil)
        } else {
            // Fallback on earlier versions
        }
    }
}
