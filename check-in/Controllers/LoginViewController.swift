//
//  LoginViewController.swift
//  check-in
//
//  Created by JediMaster on 6/25/16.
//  Copyright © 2016 JediMaster. All rights reserved.
//

import UIKit
import Localize_Swift

class LoginViewController:UIViewController {
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var usernameTextField: UITextField!
    @IBOutlet var credentialsView: UIView!
    @IBOutlet var companyIDTextField: UITextField!
    @IBOutlet var submitButton: UIButton!
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var companyNameLabel: UILabel!
    
    var activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50)) as UIActivityIndicatorView
    
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    let dataController = DataController.sharedInstance
    
    
    //------------------------------------------------------------------------------
    // MARK: Lifecycle Methods
    //------------------------------------------------------------------------------
    
    override func viewDidLoad() {
        setupActivityIndidator()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateUI_companyIdAuthentication), name: Notification.didReceiveCompanyIDNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateUI_usernamePasswordAuthentication), name: Notification.didReceiveAuthenticationNotification, object: nil)
        
        if (UserDefaults.standard.value(forKey: "companyPath") as? String) != nil {
            self.usernameTextField.isHidden = false
            self.passwordTextField.isHidden = false
            self.loginButton.isHidden = false
            self.companyNameLabel.isHidden = false
            self.submitButton.isHidden = true
            self.companyIDTextField.isHidden = true
            self.companyNameLabel.text = UserDefaults.standard.value(forKey: "companyName") as? String
            
            // This is used to pre-poluate username when demoing or developing.
            switch self.appDelegate.companyName {
            case "develop":
                self.usernameTextField.text = "develop"
                self.passwordTextField.becomeFirstResponder()
            case "demo":
                self.usernameTextField.text = "demo"
                self.passwordTextField.becomeFirstResponder()
            default:
                self.usernameTextField.text = ""
            }

        }
        else {
            self.usernameTextField.isHidden = true
            self.passwordTextField.isHidden = true
            self.loginButton.isHidden = true
            self.companyNameLabel.isHidden = true
        }
        
        self.usernameTextField.placeholder = "username".localized()
        self.passwordTextField.placeholder = "password".localized()
        self.loginButton.setTitle("Login".localized(), for: .normal)
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    //------------------------------------------------------------------------------
    // MARK: Action Methods
    //------------------------------------------------------------------------------
    @IBAction func authenticaUser(_ sender: AnyObject) {
        self.companyIDTextField.resignFirstResponder()
        self.view.addSubview(self.activityIndicator)
        self.activityIndicator.startAnimating()
        
        self.dataController.checkCredentials(self.usernameTextField.text!, password: self.passwordTextField.text!)
    }
    
    @IBAction func authenticateCompanyId(_ sender: AnyObject) {
        self.passwordTextField.resignFirstResponder()
        self.view.addSubview(self.activityIndicator)
        self.activityIndicator.startAnimating()
        
        self.dataController.setURLIdentifierForCompany(self.companyIDTextField.text!)
    }
    
    //------------------------------------------------------------------------------
    // MARK: Private Methods
    //------------------------------------------------------------------------------
    func getDocumentsDirectory() -> NSString {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory as NSString
    }
    
    func getImageFromDocumentsDirectory(_ filename: String) -> UIImage? {
        let docDir = FileManager.SearchPathDirectory.documentDirectory
        let userDomainMask = FileManager.SearchPathDomainMask.userDomainMask
        let paths = NSSearchPathForDirectoriesInDomains(docDir, userDomainMask, true)
        if paths.count > 0 {
            let dirPath: String = paths[0]
            let readPath = (dirPath as NSString).appendingPathComponent("check-in_image.png")
            if let image = UIImage(contentsOfFile: readPath) {
                return image
            }
        }
        return nil
    }
    
    func setupActivityIndidator() {
        self.activityIndicator.center = self.view.center
        self.activityIndicator.hidesWhenStopped = true
        self.activityIndicator.activityIndicatorViewStyle = .gray
    }
    
    @objc fileprivate func updateUI_usernamePasswordAuthentication(_ notification: Notification) {
        let authenticationDidPass = notification.object as! Bool
        DispatchQueue.main.async(execute: {
            
            self.activityIndicator.stopAnimating()
            
            if authenticationDidPass == true {
                self.performSegue(withIdentifier: "checkInSegue", sender: self)
                self.setCheckinImage()
                self.setCheckinImageBackgroundColor()
            }
            else {
                self.shakeView(self.credentialsView)
            }
        })
    }
    
    
    @objc fileprivate func updateUI_companyIdAuthentication(_ notification: Notification) {
        DispatchQueue.main.async(execute: {
            
            self.activityIndicator.stopAnimating()

            let didSetCompanyPath = notification.object as! Bool
            if didSetCompanyPath == true {
                self.usernameTextField.isHidden = false
                self.passwordTextField.isHidden = false
                self.loginButton.isHidden = false
                self.companyNameLabel.isHidden = false
                self.companyIDTextField.isHidden = true
                self.submitButton.isHidden = true
            }
            else {
                self.presentAlert("The company id you entered is not valid".localized(), title: "Invalid".localized())
            }
            self.companyNameLabel.text = UserDefaults.standard.value(forKey: "companyName") as? String
        })
    }
    
    fileprivate  func presentAlert(_ message: String, title: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    fileprivate func setCheckinImage() {
        // Check to see if there is an image already saved in the doc dir. If ther is then save that image to the appDelegate property. If there is not then save it to the doc dir and save to appDelegate property.
        if let companyImage = getImageFromDocumentsDirectory("check-in_image.png") {
            self.appDelegate.companyImage = companyImage
        }
        else {
            self.dataController.downloadImage { (data) in
                DispatchQueue.main.async(execute: {
                    let image = UIImage(data: data as Data)!
                    self.appDelegate.companyImage = image
                    let data = UIImagePNGRepresentation(image)
                    let fileName = self.getDocumentsDirectory().appendingPathComponent("check-in_image.png")
                    try? data?.write(to: URL(fileURLWithPath: fileName), options: [.atomic])
                })
            }
        }
    }
    
    fileprivate func setCheckinImageBackgroundColor() {
        if self.appDelegate.companyBackgroundColor == nil {
            self.dataController.getCompanySettings({ (color) in
                self.appDelegate.companyBackgroundColor = color
            })
        }
    }
    
    fileprivate func shakeView(_ shakeView: UIView) {
        let shake = CABasicAnimation(keyPath: "position")
        let xDelta = CGFloat(5)
        shake.duration = 0.15
        shake.repeatCount = 2
        shake.autoreverses = true
        
        let from_point = CGPoint(x: shakeView.center.x - xDelta, y: shakeView.center.y)
        let from_value = NSValue(cgPoint: from_point)
        
        let to_point = CGPoint(x: shakeView.center.x + xDelta, y: shakeView.center.y)
        let to_value = NSValue(cgPoint: to_point)
        
        shake.fromValue = from_value
        shake.toValue = to_value
        shake.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        shakeView.layer.add(shake, forKey: "position")
    }

    //------------------------------------------------------------------------------
    // MARK: UITexfield Delegate Methods
    //------------------------------------------------------------------------------
    func textFieldShouldReturn(_ textField: UITextField!) -> Bool {
        textField.resignFirstResponder()
        authenticaUser(self)
        return true
    }}
