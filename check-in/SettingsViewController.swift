//
//  SettingsViewController.swift
//  check-in
//
//  Created by Joel on 8/30/16.
//  Copyright © 2016 JediMaster. All rights reserved.
//

import UIKit
import MessageUI

class SettingsViewController: UIViewController {
    
    let dataController = DataController.sharedInstance
    var promotionMessageTuple: (message: String?, status: String?) = (nil, nil)
    @IBOutlet var messagesTextView: UITextView!
    @IBOutlet var statusSwitch: UISwitch!
    @IBOutlet var promotionMessageStatusLabel: UILabel!
    
    override func viewDidLoad() {
        
            }
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        if UIDevice.current.orientation == .portraitUpsideDown {
            self.tabBarController?.selectedIndex = 1
            self.tabBarController?.tabBar.isHidden = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.dataController.getPromotionalMessage { (message, status) in
            DispatchQueue.main.async(execute: {
                self.messagesTextView.text = message
                self.statusSwitch.setOn(status == "on" ? true : false, animated: true)
                self.promotionMessageStatusLabel.text = status
            })
        }
    }
    
    @IBAction func setMessage(_ sender: AnyObject) {
        updatePromotionMessage()
    }
    
    @IBAction func availabilityStatusChanged(_ sender: UISwitch) {
        updatePromotionMessage()
    }
    
    fileprivate func updatePromotionMessage() {
        self.promotionMessageTuple.message = self.messagesTextView.text
        self.promotionMessageTuple.status = self.statusSwitch.isOn == true ? "on" : "off"
        self.promotionMessageStatusLabel.text = self.promotionMessageTuple.status
        self.dataController.updatePromotionMessage(self.promotionMessageTuple)
        self.messagesTextView.resignFirstResponder()
    }
    
    //------------------------------------------------------------------------------
    // MARK: MessageComposer Delegate Methods
    //------------------------------------------------------------------------------
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        switch result.rawValue {
        case MessageComposeResult.cancelled.rawValue :
            print("message canceled")
            
        case MessageComposeResult.failed.rawValue :
            print("message failed")
            
        case MessageComposeResult.sent.rawValue :
            print("message sent")
            
        default:
            break
        }
        controller.dismiss(animated: true, completion: nil)
    }
}
