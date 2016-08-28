//
//  CheckinViewController.swift
//  check-in
//
//  Created by Joel on 8/15/16.
//  Copyright © 2016 JediMaster. All rights reserved.
//

//
//  CheckInViewController.swift
//  CheckIn-Store
//
//  Created by Joel on 7/27/16.
//  Copyright © 2016 whitecoatlabs. All rights reserved.
//

import UIKit
import CoreData

class CheckInViewController: UIViewController {
    
    @IBOutlet var phoneTextField: UITextField!
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var companyImageView: UIImageView!
    
    var stylistTable:StylistsOfferedTableViewController?
    var servicesTable:ServicesOfferedTableViewController?
    var checkinEvent: CheckInEvent?
    var serviceSelected: String?
    var stylistSelected: String?
    var stylists = [Stylist]()
    var stylistMapping = Dictionary<String, AnyObject>()
    var services = [Service]()
    var serviceMapping = Dictionary<String, AnyObject>()
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let dataController = DataController.sharedInstance
    
    //------------------------------------------------------------------------------
    // MARK: Lifecycle Methods
    //------------------------------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        if let image = self.appDelegate.companyImage {
            self.companyImageView.image = image
        }
        else {
            self.companyImageView.image = UIImage(named: "placeholder")
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        if UIDevice.currentDevice().orientation == .Portrait {
            self.tabBarController?.selectedIndex = 0
        }
    }
    
    //------------------------------------------------------------------------------
    // MARK: Private Methods
    //-----------------------------------------------------------------------------
    
    private func resetUI() {
        self.nameTextField.text = nil
        self.phoneTextField.text = nil
        self.nameTextField.resignFirstResponder()
        self.phoneTextField.resignFirstResponder()
    }
    
    private func formIsComplete() -> Bool {
        if self.nameTextField.text?.characters.count == 0 {
            presentAlert("Ingrese nombre")
            return false
        }
        else if self.phoneTextField.text?.characters.count != 13 {
            presentAlert("Ingrese numero telefonico valido")
            return false
        }
        else {
            return true
        }
    }
    
    private  func presentAlert(message: String) {
        let alert = UIAlertController(title: "Falta informacion", message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    //------------------------------------------------------------------------------
    // MARK: Action Methods
    //------------------------------------------------------------------------------
    @IBAction func submit(sender: AnyObject) {
        if (formIsComplete()) {
            self.dataController.postCheckinEvent(self.phoneTextField.text!, name: self.nameTextField.text!, completion: { 
                dispatch_async(dispatch_get_main_queue(), {
                    self.resetUI()
                })
            })
        }
    }
    
    //------------------------------------------------------------------------------
    // MARK: UITextField Delegate Methods
    //------------------------------------------------------------------------------
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool
    {
        if textField == self.phoneTextField
        {
            let newString = (textField.text! as NSString).stringByReplacingCharactersInRange(range, withString: string)
            let components = newString.componentsSeparatedByCharactersInSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet)
            let decimalString = components.joinWithSeparator("") as NSString
            
            let length = decimalString.length
            let hasLeadingOne = length > 0 && decimalString.characterAtIndex(0) == (1 as unichar)
            
            if length == 0 || (length > 10 && !hasLeadingOne) || length > 11
            {
                let newLength = (textField.text! as NSString).length + (string as NSString).length - range.length as Int
                
                return (newLength > 10) ? false : true
            }
            var index = 0 as Int
            let formattedString = NSMutableString()
            
            if hasLeadingOne
            {
                formattedString.appendString("1 ")
                index += 1
            }
            if (length - index) > 3
            {
                let areaCode = decimalString.substringWithRange(NSMakeRange(index, 3))
                formattedString.appendFormat("(%@)", areaCode)
                index += 3
            }
            if length - index > 3
            {
                let prefix = decimalString.substringWithRange(NSMakeRange(index, 3))
                formattedString.appendFormat("%@-", prefix)
                index += 3
            }
            
            let remainder = decimalString.substringFromIndex(index)
            formattedString.appendString(remainder)
            textField.text = formattedString as String
            
            return false
        }
        else
        {
            return true
        }
    }
}

class Stylist: NSObject {
    var status: String!
    var id: String!
    var name: String!
    
    init(status: String, id: String, name: String) {
        self.status = status
        self.id = id
        self.name = name
    }
}

class Service: NSObject {
    var name: String!
    var id: String!
    var status: String!
    
    init(name: String, id: String, status: String) {
        self.name = name
        self.id = id
        self.status = status
    }
}

class Payment: NSObject {
    var name: String!
    var id: String!
    var status: String!
    
    init(name: String, id: String, status: String) {
        self.name = name
        self.id = id
        self.status = status
    }
}