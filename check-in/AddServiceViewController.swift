//
//  AddServiceViewController.swift
//  check-in
//
//  Created by Joel on 8/8/16.
//  Copyright © 2016 JediMaster. All rights reserved.
//

import UIKit

protocol AddServiceVCDelegate {
    func didEnterServiceName(name: String)
}

class AddServiceViewController: UIViewController {
    
    @IBOutlet var nameTextField: UITextField!
    var delegate: AddServiceVCDelegate?
    
    @IBAction func addStylist(sender: AnyObject) {
        if self.nameTextField.text?.characters.count > 0 {
            self.delegate?.didEnterServiceName(self.nameTextField.text!)
        }
        sender.resignFirstResponder()
    }
}