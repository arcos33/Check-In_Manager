//
//  AddStylistViewController.swift
//  check-in
//
//  Created by Joel on 8/5/16.
//  Copyright © 2016 JediMaster. All rights reserved.
//

import UIKit

protocol AddStylistVCDelegate {
    func didEnterStylistName(name: String)
}

class AddStylistViewController: UIViewController {
    
    @IBOutlet var nameTextField: UITextField!
    var delegate: AddStylistVCDelegate?
    
    @IBAction func addStylist(sender: AnyObject) {
        if self.nameTextField.text?.characters.count > 0 {
            self.delegate?.didEnterStylistName(self.nameTextField.text!)
        }
        sender.resignFirstResponder()
    }
}
