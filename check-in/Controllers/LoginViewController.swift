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
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    @IBAction func authenticaUser(sender: AnyObject) {
        if (usernameTextField.text == "glamour") && passwordTextField.text == "glamour"  {
            performSegueWithIdentifier("checkInSegue", sender: sender)
        }
        else {
            shakeView(credentialsView)
        }
    }
    func shakeView(shakeView: UIView) {
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
