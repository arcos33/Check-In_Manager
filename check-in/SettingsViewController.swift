//
//  SettingsViewController.swift
//  check-in
//
//  Created by Joel on 8/30/16.
//  Copyright © 2016 JediMaster. All rights reserved.
//

import UIKit
import MessageUI

class SettingsViewController: UIViewController, MFMessageComposeViewControllerDelegate {
    
    let dataController = DataController.sharedInstance
    var promotionMessageTuple: (message: String?, status: String?) = (nil, nil)
    @IBOutlet var messagesTextView: UITextView!
    @IBOutlet var statusSwitch: UISwitch!
    @IBOutlet var promotionMessageStatusLabel: UILabel!
    
    override func viewDidLoad() {
        
            }
    
    override func viewWillAppear(animated: Bool) {
        self.dataController.getPromotionalMessage { (message, status) in
            dispatch_async(dispatch_get_main_queue(), {
                self.messagesTextView.text = message
                self.statusSwitch.setOn(status == "on" ? true : false, animated: true)
                self.promotionMessageStatusLabel.text = status
            })
        }
    }
    
    @IBAction func setMessage(sender: AnyObject) {
        sendMessage()
        //updatePromotionMessage()
    }
    
    @IBAction func availabilityStatusChanged(sender: UISwitch) {
        updatePromotionMessage()
    }
    
    private func updatePromotionMessage() {
        self.promotionMessageTuple.message = self.messagesTextView.text
        self.promotionMessageTuple.status = self.statusSwitch.on == true ? "on" : "off"
        self.promotionMessageStatusLabel.text = self.promotionMessageTuple.status
        self.dataController.updatePromotionMessage(self.promotionMessageTuple)
        self.messagesTextView.resignFirstResponder()
    }
    
    //------------------------------------------------------------------------------
    // MARK: MessageComposer Delegate Methods
    //------------------------------------------------------------------------------
    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        switch result.rawValue {
        case MessageComposeResultCancelled.rawValue :
            print("message canceled")
            
        case MessageComposeResultFailed.rawValue :
            print("message failed")
            
        case MessageComposeResultSent.rawValue :
            print("message sent")
            
        default:
            break
        }
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func sendMessage() {
        let messageVC = MFMessageComposeViewController()
        messageVC.body = "Message string"
        messageVC.recipients = ["8016861991"] // Optionally add some tel numbers
        messageVC.messageComposeDelegate = self
        // Open the SMS View controller
        presentViewController(messageVC, animated: true, completion: nil)
    }
}
