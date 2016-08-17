//
//  NSUserDefaults+CheckIn.swift
//  check-in
//
//  Created by Joel on 8/15/16.
//  Copyright © 2016 JediMaster. All rights reserved.
//

import UIKit

extension NSUserDefaults {
    func createUniqueID() -> Int {
        let uniqueID = self.integerForKey("uniqueID")
        self.setInteger(uniqueID + 1, forKey: "uniqueID")
        self.synchronize()
        
        return uniqueID
    }
}