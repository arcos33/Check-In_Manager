//
//  LoginViewController.swift
//  check-in
//
//  Created by JediMaster on 6/25/16.
//  Copyright © 2016 JediMaster. All rights reserved.
//

import UIKit

class LoginViewController:UIViewController {
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var usernameTextField: UITextField!
    @IBOutlet var credentialsView: UIView!
    @IBOutlet var companyIDTextField: UITextField!
    @IBOutlet var submitButton: UIButton!
    @IBOutlet var loginButton: UIButton!
    
    @IBOutlet var companyNameLabel: UILabel!
    var appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let dataController = DataController.sharedInstance
    
    
    //------------------------------------------------------------------------------
    // MARK: Lifecycle Methods
    //------------------------------------------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(updateUI_companyIdAuthentication), name: "DataControllerDidReceiveCompanyIDNotification", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(updateUI_usernamePasswordAuthentication), name: "DataControllerDidReceiveAuthenticationNotification", object: nil)
        
        if (NSUserDefaults.standardUserDefaults().valueForKey("companyPath") as? String) != nil {
            self.usernameTextField.hidden = false
            self.passwordTextField.hidden = false
            self.loginButton.hidden = false
            self.companyNameLabel.hidden = false
            self.submitButton.hidden = true
            self.companyIDTextField.hidden = true
            self.companyNameLabel.text = NSUserDefaults.standardUserDefaults().valueForKey("companyName") as? String

        }
        else {
            self.usernameTextField.hidden = true
            self.passwordTextField.hidden = true
            self.loginButton.hidden = true
            self.companyNameLabel.hidden = true
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    //------------------------------------------------------------------------------
    // MARK: Action Methods
    //------------------------------------------------------------------------------
    @IBAction func authenticaUser(sender: AnyObject) {
        self.dataController.checkCredentials(self.usernameTextField.text!, password: self.passwordTextField.text!)
    }
    
    @IBAction func authenticateCompanyId(sender: AnyObject) {
        self.dataController.setURLIdentifierForCompany(self.companyIDTextField.text!)
    }
    
    //------------------------------------------------------------------------------
    // MARK: Private Methods
    //------------------------------------------------------------------------------
    @objc private func updateUI_usernamePasswordAuthentication(notification: NSNotification) {
        let authenticationDidPass = notification.object as! Bool
        if authenticationDidPass == true {
            dispatch_async(dispatch_get_main_queue(), {
                self.performSegueWithIdentifier("checkInSegue", sender: self)
            })
        }
        else {
            dispatch_async(dispatch_get_main_queue(), {
                self.shakeView(self.credentialsView)
            })
        }
    }
    
    @objc private func updateUI_companyIdAuthentication(notification: NSNotification) {
        let didSetCompanyPath = notification.object as! Bool
        if didSetCompanyPath == true {
            dispatch_async(dispatch_get_main_queue(), {
                self.usernameTextField.hidden = false
                self.passwordTextField.hidden = false
                self.loginButton.hidden = false
                self.companyNameLabel.hidden = false
                self.companyIDTextField.hidden = true
                self.submitButton.hidden = true
            })
        }
        else {
            dispatch_async(dispatch_get_main_queue(), {
                self.presentAlert("El numero que ingreso no es valido", title: "Invalido")
            })
        }
        dispatch_async(dispatch_get_main_queue()) {
            self.companyNameLabel.text = NSUserDefaults.standardUserDefaults().valueForKey("companyName") as? String
        }
    }
    
    private  func presentAlert(message: String, title: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    private func shakeView(shakeView: UIView) {
        let shake = CABasicAnimation(keyPath: "position")
        let xDelta = CGFloat(5)
        shake.duration = 0.15
        shake.repeatCount = 2
        shake.autoreverses = true
        
        let from_point = CGPointMake(shakeView.center.x - xDelta, shakeView.center.y)
        let from_value = NSValue(CGPoint: from_point)
        
        let to_point = CGPointMake(shakeView.center.x + xDelta, shakeView.center.y)
        let to_value = NSValue(CGPoint: to_point)
        
        shake.fromValue = from_value
        shake.toValue = to_value
        shake.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        shakeView.layer.addAnimation(shake, forKey: "position")
    }
}
