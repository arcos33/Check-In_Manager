//
//  StylistsOfferedTableViewController.swift
//  check-in
//
//  Created by Joel on 8/15/16.
//  Copyright © 2016 JediMaster. All rights reserved.
//

import UIKit

protocol StylistsOfferedTableDelegate {
    func didSelectStylist(_ stylist: String)
}

class StylistsOfferedTableViewController: UITableViewController {
    
    var stylistsOffered = [Stylist]()
    var didSetStylist:Bool!
    var stylistSelected:String!
    var delegate: StylistsOfferedTableDelegate?
    let dataController = DataController.sharedInstance
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    //------------------------------------------------------------------------------
    // MARK: Lifecycle Methods
    //------------------------------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
            }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    //------------------------------------------------------------------------------
    // MARK: TableView Methods
    //------------------------------------------------------------------------------
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Try to get a cell
        let stylist = self.stylistsOffered[(indexPath as NSIndexPath).row] as Stylist
        let cell = UITableViewCell()
        cell.textLabel?.text = stylist.name!
        cell.textLabel?.textAlignment = .center
        return cell
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.stylistsOffered.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.didSetStylist = true
        let stylist = self.stylistsOffered[(indexPath as NSIndexPath).row]
        self.stylistSelected = stylist.name!
        self.dismiss(animated: true) { 
            self.delegate?.didSelectStylist(stylist.name!)
        }
    }
}
