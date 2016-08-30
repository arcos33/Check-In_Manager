//
//  ReportsViewController.swift
//  check-in
//
//  Created by Joel on 8/8/16.
//  Copyright © 2016 JediMaster. All rights reserved.
//

import Foundation
import UIKit
import MessageUI
import PDFGenerator
import CoreData

class ReportsViewController: UIViewController, MFMailComposeViewControllerDelegate{
    // declare MIME (Multipurpose Internet Mail Extension)
    // it defines what kind of information to send via email
    private enum MIMEType: String {
        case pdf = "application/pdf"
        case png = "image/png"
        
        init? (type: String) {
            switch type.lowercaseString {
            case "png": self = .png
            case "pdf": self = .pdf
            default: return nil
            }
        }
    }
    
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var sendPDFButton: UIButton!
    @IBOutlet var tableview: UITableView!
    
    var titleLabel: UILabel!
    let cellIdentifier = "reportsCell"
    var appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var checkinEvents = [CheckInEvent]()
    
    //------------------------------------------------------------------------------
    // MARK: Lifecycle Methods
    //------------------------------------------------------------------------------
    override func viewDidLoad() {
        self.titleLabel = UILabel(frame: CGRectMake(280, 100, 700, 50))
        let df = NSDateFormatter()
        df.dateFormat = "MM-dd-yyyy"
        let dateString = df.stringFromDate(NSDate.getCurrentLocalDate())
        self.titleLabel.text = "Reporte de dia (\(dateString))"
        self.view.addSubview(self.titleLabel)
        self.titleLabel.hidden = true
        
        let dataController = DataController.sharedInstance
        dataController.getCheckinRecords()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(update), name: "DataControllerDidReceiveCheckinRecordsNotification", object: nil)
    }
    
    //------------------------------------------------------------------------------
    // MARK: Tableview Methods
    //------------------------------------------------------------------------------
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let reportsHeaderView = tableview.dequeueReusableCellWithIdentifier("reportsHeaderView") as! ReportsHeaderView
        return reportsHeaderView
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return self.checkinEvents.count
    }
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        let cell = tableView.dequeueReusableCellWithIdentifier(self.cellIdentifier)! as! ReportsCustomCell
        let checkinEvent = self.checkinEvents[indexPath.row]
        cell.countLabel.text = String(indexPath.row + 1)
        cell.clientNameLabel.text = checkinEvent.name
        let df = NSDateFormatter()
        df.dateFormat = "MM/dd/yy h:mm a"
        let dateString = df.stringFromDate(checkinEvent.checkinTimestamp!)
        cell.checkintTimeLabel.text = dateString
        cell.serviceTypeLabel.text = checkinEvent.service
        cell.stylistLabel.text = checkinEvent.stylist
        return cell
    }
    
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        let alert = UIAlertController(title: "Item selected", message: "You selected item \(indexPath.row)", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    //------------------------------------------------------------------------------
    // MARK: Action Methods
    //------------------------------------------------------------------------------
    @IBAction func sendEmailWithAttachment(sender: AnyObject) {
        if self.emailTextField.text?.characters.count > 0 {
            //self.emailTextField.resignFirstResponder()
            let identifier = String(NSDate.getCurrentLocalDate())
            generatePDF(identifier)
            //createPdfFromView(self.tableview, saveToDocumentsWithIdentifier: identifier)
        }
        else {
            alert("Correo Electronico", message: "Necesita ingresar un correo electronico")
        }
    }
    
    //------------------------------------------------------------------------------
    // MARK: Private Methods
    //------------------------------------------------------------------------------
    @objc private func update(notification: NSNotification) {
        dispatch_async(dispatch_get_main_queue()) { 
            let fetch = NSFetchRequest(entityName: "CheckInEvent")
            do {
                self.checkinEvents = try self.appDelegate.managedObjectContext.executeFetchRequest(fetch) as! [CheckInEvent]
            }
            catch {
                print("Class:\(#file)\n Line:\(#line)\n Error:\(error)")
            }
            
            self.tableview.reloadData()
        }
    }
    
    private func createPdfFromView(aView: UIView, saveToDocumentsWithIdentifier fileName: String)
    {
        self.emailTextField.hidden = true
        self.sendPDFButton.hidden = true
        self.titleLabel.hidden = false
        
        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, aView.bounds, nil)
        UIGraphicsBeginPDFPage()
        
        guard let pdfContext = UIGraphicsGetCurrentContext() else { return }
        
        aView.layer.renderInContext(pdfContext)
        UIGraphicsEndPDFContext()
        self.emailTextField.hidden = false
        self.sendPDFButton.hidden = false
        self.titleLabel.hidden = true
        
        if let documentDirectories = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first {
            let filePath = documentDirectories + "/" + fileName
            pdfData.writeToFile(filePath, atomically: true)
            showMailComposerWith(filePath, fileName: fileName)
        }
    }
    
    private func alert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    private func showMailComposerWith(filePath: String, fileName: String) {
        if MFMailComposeViewController.canSendMail() {
            let subject = "Reporte"
            let messageBody = "Reporte de fin de dia"
            let toRecipient = self.emailTextField.text
            let mailComposer = MFMailComposeViewController()
            mailComposer.mailComposeDelegate = self
            mailComposer.setSubject(subject)
            mailComposer.setMessageBody(messageBody, isHTML: true)
            mailComposer.setToRecipients([toRecipient!])

            if let fileData = NSData(contentsOfFile: filePath) {
                mailComposer.addAttachmentData(fileData, mimeType: "application/pdf", fileName: fileName)
                presentViewController(mailComposer, animated: true, completion: nil)
            }
        }
        else {
            alert("Email", message: "Este iPad no ha sido configurado con una cuenta de email")
        }
    }
    
    func generatePDF(fileName: String) {
        let v1 = self.tableview
        let identifier = String(NSDate.getCurrentLocalDate())
        let documentDirectories = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first
        let dst = documentDirectories! + "/" + fileName
        
        // outputs as NSData
        do {
            let data = try PDFGenerator.generate([v1])
            data.writeToFile(dst, atomically: true)
        } catch (let error) {
            print(error)
        }
        
        // writes to Disk directly.
        do {
            try PDFGenerator.generate([v1], outputPath: dst)
        } catch (let error) {
            print(error)
        }
        showMailComposerWith(dst, fileName: identifier)
    }
    
    //------------------------------------------------------------------------------
    // MARK: MFMailComposeViewControllerDelegate Methods
    //------------------------------------------------------------------------------
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        dismissViewControllerAnimated(true, completion: nil)

        switch result.rawValue {
        case MFMailComposeResultFailed.rawValue:
            alert("failed", message: (error?.localizedDescription)!)
        default: return
        }
    }
}
