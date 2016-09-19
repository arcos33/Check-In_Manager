//
//  SettingsViewController.swift
//  check-in
//
//  Created by Joel on 8/30/16.
//  Copyright © 2016 JediMaster. All rights reserved.
//

import UIKit
import MessageUI
import Localize_Swift

class SettingsViewController: UIViewController {
    
    let dataController = DataController.sharedInstance
    var promotionMessageTuple: (message: String?, status: String?) = (nil, nil)
    @IBOutlet var messagesTextView: UITextView!
    @IBOutlet var statusSwitch: UISwitch!
    @IBOutlet var switchStatusLabel: UILabel!
    @IBOutlet var languageSwitch: UISwitch!
    @IBOutlet var messagesTitleLabel: UILabel!
    @IBOutlet var servicesTitleLabel: UILabel!
    @IBOutlet var languageTitleLabel: UILabel!
    @IBOutlet var mainTitleLabel: UILabel!
    @IBOutlet var setButton: UIButton!
    @IBOutlet var spanishLabel: UILabel!
    @IBOutlet var englishLabel: UILabel!
    //------------------------------------------------------------------------------
    // MARK: Life Cycle Methods
    //------------------------------------------------------------------------------
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        if UIDevice.current.orientation == .portraitUpsideDown {
            self.tabBarController?.selectedIndex = 1
            self.tabBarController?.tabBar.isHidden = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let curLang = Localize.currentLanguage()
        if curLang == "es-MX" { languageSwitch.isOn = true }
        else { languageSwitch.isOn = false }

        setText()
        
        self.dataController.getPromotionalMessage { (message, status) in
            DispatchQueue.main.async(execute: {
                self.messagesTextView.text = message
                self.statusSwitch.setOn(status == "on" ? true : false, animated: false)
                self.switchStatusLabel.text = status
            })
        }
        
        self.englishLabel.textColor = self.languageSwitch.isOn == true ? UIColor.lightGray : UIColor.black
        self.spanishLabel.textColor = self.languageSwitch.isOn == true ? UIColor.black : UIColor.lightGray

    }
    

    //------------------------------------------------------------------------------
    // MARK: Private Methods
    //------------------------------------------------------------------------------

    fileprivate func updatePromotionMessage() {
        self.promotionMessageTuple.message = self.messagesTextView.text
        self.promotionMessageTuple.status = self.statusSwitch.isOn == true ? "on".localized() : "off".localized()
        self.switchStatusLabel.text = self.promotionMessageTuple.status
        self.dataController.updatePromotionMessage(self.promotionMessageTuple)
        self.messagesTextView.resignFirstResponder()
    }
    
    fileprivate func setText() {
        self.mainTitleLabel.text = "Settings".localized()
        self.servicesTitleLabel.text = "Services".localized()
        self.languageTitleLabel.text = "Language".localized()
        self.messagesTitleLabel.text = "Message".localized()
        self.switchStatusLabel.text = self.statusSwitch.isOn == true ? "on".localized() : "off".localized()
        self.setButton.setTitle("Set".localized(), for: .normal)
    }
    
    //------------------------------------------------------------------------------
    // MARK: Action Methods
    //------------------------------------------------------------------------------
    @IBAction func setMessage(_ sender: AnyObject) {
        updatePromotionMessage()
    }
    
    @IBAction func availabilityStatusChanged(_ sender: UISwitch) {
        updatePromotionMessage()
    }
    

    
    @IBAction func languageChanged(_ sender: UISwitch) {
        var curLang = Localize.currentLanguage()
        if curLang == "es-MX" {
            sender.isOn = false
            curLang = "eng"
            self.englishLabel.textColor = UIColor.black
            self.spanishLabel.textColor = UIColor.lightGray
        }
        else {
            sender.isOn = true
            curLang = "es-MX"
            self.englishLabel.textColor = UIColor.lightGray
            self.spanishLabel.textColor = UIColor.black
        }
        
        Localize.setCurrentLanguage(curLang)
        setText()
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
