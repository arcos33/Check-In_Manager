//
//  NSUserDefaults+CheckIn.swift
//  check-in
//
//  Created by Joel on 8/15/16.
//  Copyright © 2016 JediMaster. All rights reserved.
//

import UIKit

extension UserDefaults {
    func createUniqueID() -> Int {
        let uniqueID = self.integer(forKey: "uniqueID")
        self.set(uniqueID + 1, forKey: "uniqueID")
        self.synchronize()
        
        return uniqueID
    }
}
