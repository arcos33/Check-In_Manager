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
    
    //------------------------------------------------------------------------------
    // MARK: Lifecycle Methods
    //------------------------------------------------------------------------------
    override func viewDidLoad() {
        self.titleLabel = UILabel(frame: CGRectMake(280, 100, 700, 50))
        let df = NSDateFormatter()
        df.dateFormat = "MM-dd-yyyy"
        let dateString = df.stringFromDate(NSDate())
        self.titleLabel.text = "Reporte de dia (\(dateString))"
        self.view.addSubview(self.titleLabel)
        self.titleLabel.hidden = true
    }
    
    //------------------------------------------------------------------------------
    // MARK: Tableview Methods
    //------------------------------------------------------------------------------
    func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return 150
    }
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        let cell = tableView.dequeueReusableCellWithIdentifier(self.cellIdentifier)! as UITableViewCell
        cell.textLabel!.text = "hi"
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
            let identifier = String(NSDate())
            createPdfFromView(self.tableview, saveToDocumentsWithIdentifier: identifier)
        }
        else {
            alert("Correo Electronico", message: "Necesita ingresar un correo electronico")
        }
    }
    
    //------------------------------------------------------------------------------
    // MARK: Private Methods
    //------------------------------------------------------------------------------
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
