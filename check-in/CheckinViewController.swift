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
import Localize_Swift

class CheckInViewController: UIViewController {
    
    @IBOutlet var phoneTextField: UITextField!
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var companyImage: UIImageView!
    @IBOutlet var companyImageView: UIView!
    @IBOutlet var checkInButton: UIButton!
    
    var stylistTable:StylistsOfferedTableViewController?
    var servicesTable:ServicesOfferedTableViewController?
    var checkinEvent: CheckInEvent?
    var serviceSelected: String?
    var stylistSelected: String?
    var stylists = [Stylist]()
    var stylistMapping = Dictionary<String, AnyObject>()
    var services = [Service]()
    var serviceMapping = Dictionary<String, AnyObject>()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let dataController = DataController.sharedInstance
    var tabBarControllerRef: UITabBarController?
    var tabSelected: Int!
    
    //------------------------------------------------------------------------------
    // MARK: Lifecycle Methods
    //------------------------------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(setText), name: Notification.languageChangeNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setText()
        
        
        if let image = self.appDelegate.companyImage {
            self.companyImage.image = image
        }
        else {
            self.companyImage.image = UIImage(named: "placeholder")
        }
        if let backgroundColor = self.appDelegate.companyBackgroundColor {
            self.companyImageView.backgroundColor = backgroundColor
        }
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        if UIDevice.current.orientation == .portrait {
            self.dismiss(animated: true, completion: { 
                self.tabBarControllerRef?.selectedIndex = self.tabSelected
            })
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //------------------------------------------------------------------------------
    // MARK: Private Methods
    //-----------------------------------------------------------------------------
    @objc fileprivate func setText() {
        self.nameTextField.placeholder = "Name".localized()
        self.phoneTextField.placeholder = "Mobile Number".localized()
        self.checkInButton.setTitle("Check in".localized(), for: .normal)
    }
    
    fileprivate func resetUI() {
        self.nameTextField.text = nil
        self.phoneTextField.text = nil
        self.nameTextField.resignFirstResponder()
        self.phoneTextField.resignFirstResponder()
    }
    
    fileprivate func formIsComplete() -> Bool {
        if self.nameTextField.text?.characters.count == 0 {
            presentAlert("Enter name".localized())
            return false
        }
        else if self.phoneTextField.text?.characters.count != 13 {
            presentAlert("Enter a valid mobile number".localized())
            return false
        }
        else {
            return true
        }
    }
    
    fileprivate  func presentAlert(_ message: String) {
        let alert = UIAlertController(title: "Missing Information".localized(), message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    //------------------------------------------------------------------------------
    // MARK: Action Methods
    //------------------------------------------------------------------------------
    @IBAction func submit(_ sender: AnyObject) {
        if (formIsComplete()) {
            self.dataController.postCheckinEvent(self.phoneTextField.text!, name: self.nameTextField.text!, completion: { 
                DispatchQueue.main.async(execute: {
                    self.resetUI()
                })
            })
        }
    }
    
    //------------------------------------------------------------------------------
    // MARK: UITextField Delegate Methods
    //------------------------------------------------------------------------------
    func textField(_ textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool
    {
        if textField == self.phoneTextField
        {
            let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
            let components = newString.components(separatedBy: CharacterSet.decimalDigits.inverted)
            let decimalString = components.joined(separator: "") as NSString
            
            let length = decimalString.length
            let hasLeadingOne = length > 0 && decimalString.character(at: 0) == (1 as unichar)
            
            if length == 0 || (length > 10 && !hasLeadingOne) || length > 11
            {
                let newLength = (textField.text! as NSString).length + (string as NSString).length - range.length as Int
                
                return (newLength > 10) ? false : true
            }
            var index = 0 as Int
            let formattedString = NSMutableString()
            
            if hasLeadingOne
            {
                formattedString.append("1 ")
                index += 1
            }
            if (length - index) > 3
            {
                let areaCode = decimalString.substring(with: NSMakeRange(index, 3))
                formattedString.appendFormat("(%@)", areaCode)
                index += 3
            }
            if length - index > 3
            {
                let prefix = decimalString.substring(with: NSMakeRange(index, 3))
                formattedString.appendFormat("%@-", prefix)
                index += 3
            }
            
            let remainder = decimalString.substring(from: index)
            formattedString.append(remainder)
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
