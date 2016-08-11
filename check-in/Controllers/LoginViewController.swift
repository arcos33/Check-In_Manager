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
    
    var appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    //------------------------------------------------------------------------------
    // MARK: Lifecycle Methods
    //------------------------------------------------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(goToMainUI), name: "didSetUser", object: nil)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    //------------------------------------------------------------------------------
    // MARK: Action Methods
    //------------------------------------------------------------------------------
    @IBAction func authenticaUser(sender: AnyObject) {
        let dataController = DataController.sharedInstance
        dataController.setURLIdentifierForUser(self.usernameTextField.text!)
    }
    
    //------------------------------------------------------------------------------
    // MARK: Private Methods
    //------------------------------------------------------------------------------
    @objc private func goToMainUI() {
        if (self.usernameTextField.text == "demo" || self.usernameTextField.text == "develop") {
            dispatch_async(dispatch_get_main_queue(), { 
                self.performSegueWithIdentifier("checkInSegue", sender: self)
            })
        }
        else {
            if (self.usernameTextField.text == "glamour") && passwordTextField.text == "glamour"  {
                dispatch_async(dispatch_get_main_queue(), {
                    self.performSegueWithIdentifier("checkInSegue", sender: self)
                    })
            }
            else {
                shakeView(credentialsView)
            }
        }
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
