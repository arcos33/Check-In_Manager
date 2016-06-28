//
//  InactiveClientsViewController.swift
//  check-in
//
//  Created by Joel on 6/28/16.
//  Copyright © 2016 JediMaster. All rights reserved.
//

import Foundation
import UIKit

class InactiveClientsViewController: UIViewController {
    @IBOutlet var tableview: UITableView!
    
    override func viewDidLoad() {
        self.tableview.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return UITableViewCell()
    }

}
