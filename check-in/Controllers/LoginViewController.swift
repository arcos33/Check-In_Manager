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
    
    var activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50)) as UIActivityIndicatorView
    
    var appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let dataController = DataController.sharedInstance
    
    
    //------------------------------------------------------------------------------
    // MARK: Lifecycle Methods
    //------------------------------------------------------------------------------
    
    override func viewDidLoad() {
        setupActivityIndidator()
        
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
        self.companyIDTextField.resignFirstResponder()
        self.view.addSubview(self.activityIndicator)
        self.activityIndicator.startAnimating()
        
        self.dataController.checkCredentials(self.usernameTextField.text!, password: self.passwordTextField.text!)
    }
    
    @IBAction func authenticateCompanyId(sender: AnyObject) {
        self.passwordTextField.resignFirstResponder()
        self.view.addSubview(self.activityIndicator)
        self.activityIndicator.startAnimating()

        self.dataController.setURLIdentifierForCompany(self.companyIDTextField.text!)
    }
    
    //------------------------------------------------------------------------------
    // MARK: Private Methods
    //------------------------------------------------------------------------------
    func setupActivityIndidator() {
        self.activityIndicator.center = self.view.center
        self.activityIndicator.hidesWhenStopped = true
        self.activityIndicator.activityIndicatorViewStyle = .Gray
    }
    
    @objc private func updateUI_usernamePasswordAuthentication(notification: NSNotification) {
        let authenticationDidPass = notification.object as! Bool
        dispatch_async(dispatch_get_main_queue(), {
            
            self.activityIndicator.stopAnimating()
            
            if authenticationDidPass == true {
                self.performSegueWithIdentifier("checkInSegue", sender: self)
            }
            else {
                self.shakeView(self.credentialsView)
            }
        })
    }
    
    
    @objc private func updateUI_companyIdAuthentication(notification: NSNotification) {
        dispatch_async(dispatch_get_main_queue(), {
            
            self.activityIndicator.stopAnimating()

            let didSetCompanyPath = notification.object as! Bool
            if didSetCompanyPath == true {
                self.usernameTextField.hidden = false
                self.passwordTextField.hidden = false
                self.loginButton.hidden = false
                self.companyNameLabel.hidden = false
                self.companyIDTextField.hidden = true
                self.submitButton.hidden = true
            }
            else {
                self.presentAlert("El numero que ingreso no es valido", title: "Invalido")
            }
            self.companyNameLabel.text = NSUserDefaults.standardUserDefaults().valueForKey("companyName") as? String
        })
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
