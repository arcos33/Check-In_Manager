//
//  AddStylistViewController.swift
//  check-in
//
//  Created by Joel on 8/5/16.
//  Copyright © 2016 JediMaster. All rights reserved.
//

import UIKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


protocol AddStylistVCDelegate {
    func didEnterStylistName(_ name: String)
}

class AddStylistViewController: UIViewController {
    
    @IBOutlet var nameTextField: UITextField!
    var delegate: AddStylistVCDelegate?
    
    @IBAction func addStylist(_ sender: AnyObject) {
        if self.nameTextField.text?.characters.count > 0 {
            self.delegate?.didEnterStylistName(self.nameTextField.text!)
        }
        self.nameTextField.resignFirstResponder()
    }
}
