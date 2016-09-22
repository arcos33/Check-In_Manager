//
//  IndustryHelper.swift
//  check-in
//
//  Created by Joel on 9/21/16.
//  Copyright © 2016 JediMaster. All rights reserved.
//

import Foundation
import UIKit

class IndustryHelper: NSObject {
    
    static func getName() -> String {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        switch appDelegate.companyIndustry {
        case "hair":
            return "Stylist".localized()
        case "chiro":
            return "Doctor".localized()
        case "dentist":
            return "Dentist".localized()
        case "nail":
            return "Technician".localized()
        case "clinic":
            return "Doctor".localized()
        case "tax":
            return "Preparer".localized()
        case "spa":
            return "Therapist".localized()
        default:
            return "Technician"
        }
    }
}
