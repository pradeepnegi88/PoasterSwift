//
//  SettingsViewController.swift
//  poaster
//
//  Created by Amol Patil on 03/03/16.
//  Copyright © 2016 Vinod Sobale. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Foundation
import MessageUI
import Mixpanel
import TwitterKit

class SettingsViewController: UIViewController, MFMailComposeViewControllerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var mainTableView: UITableView!
    var settingItems: [String] = ["Email For Help", "Change Password", "Change Marketing Button", "Poaster 101", "Stripe Dashboard", "Logout"]
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainTableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func emailBtnClicked()
    {
        let mailComposeViewController = configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail()
        {
            self.presentViewController(mailComposeViewController, animated: true, completion: nil)
        } else {
            self.showSendMailErrorAlert()
        }
    }
    
    @IBAction func closeBtnClicked(sender: AnyObject)
    {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    func changePasswordBtnClicked() {
        let changePasswordVC = self.storyboard?.instantiateViewControllerWithIdentifier("changePasswordStoryId") as! ChangePasswordViewController
       
        
        let navigationController = UINavigationController(rootViewController: changePasswordVC)
        
        self.presentViewController(navigationController, animated: true, completion: nil)

        
    }
    
    func editDefaultActionsBtnClicked() {
        let editDefActionVC  = self.storyboard?.instantiateViewControllerWithIdentifier("EditDefaultActId") as! EditDefaultActionViewController
        
        let navigationController = UINavigationController(rootViewController: editDefActionVC)
        self.presentViewController(navigationController, animated: true, completion: nil)

    }
    
    func signOutBtnClicked() {
        let alert = UIAlertController(title: "", message: "Are you sure?", preferredStyle: UIAlertControllerStyle.ActionSheet)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: { action in
            switch action.style
            {
            case .Default:
                print("default")
                
            case .Cancel:
                print("cancel")
                
            case .Destructive:
                print("destructive")
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Logout", style: .Default, handler: { action in
            switch action.style
            {
            case .Default:
                print("default")
                PoasterUtility.sharedInstance.resetAllUserDefaultsValues();
                
                FBSDKLoginManager().logOut()

                let store = Twitter.sharedInstance().sessionStore
                
                if let userID = store.session()?.userID {
                    store.logOutUserID(userID)
                }
                
                let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                var initialViewController:UIViewController
                initialViewController = storyboard.instantiateViewControllerWithIdentifier("initialVC")
                
                delegate.window?.rootViewController = initialViewController
                delegate.window?.makeKeyAndVisible()
                
            case .Cancel:
                print("cancel")
                
            case .Destructive:
                print("destructive")
            }
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        
        mailComposerVC.setToRecipients(["support@poasterapp.com"])
        mailComposerVC.setSubject("Sending you an in-Poaster e-mail...")
        mailComposerVC.setMessageBody("Sending e-mail in-app is not so bad!", isHTML: false)
        
        return mailComposerVC
    }
    
    func visitPoaster101() {
        let url = NSURL(string: "http://poasterapp.com/poaster101")!
        UIApplication.sharedApplication().openURL(url)
    }

    func visitStripeLogin() {
        let url = NSURL(string: "https://dashboard.stripe.com/login")!
        UIApplication.sharedApplication().openURL(url)
    }

    
    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertView(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", delegate: self, cancelButtonTitle: "OK")
        sendMailErrorAlert.show()
    }
    
    // MARK: MFMailComposeViewControllerDelegate Method
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.settingItems.count;
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("CELL") as UITableViewCell!
        if (cell == nil) {
            cell = UITableViewCell(style:.Default, reuseIdentifier: "CELL")
        }
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator;
        cell.accessoryView?.backgroundColor =  UIColor.whiteColor()
        
        let font = UIFont(name: "ProximaNova-Regular", size: 16)!
        cell.textLabel?.font = font
        cell.textLabel!.text = self.settingItems[indexPath.row]
//        cell.selectionStyle = UITableViewCellSelectionStyle.None
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        switch indexPath.row
        {
        case 0  :  //Email
            emailBtnClicked()
            Mixpanel.mainInstance().track(event: "Email for help tapped")
            break
            
        case 1  : //change password
            changePasswordBtnClicked()
            Mixpanel.mainInstance().track(event: "Change password tapped")
            break

        case 2  : //edit default actions
            editDefaultActionsBtnClicked()
            Mixpanel.mainInstance().track(event: "Settings - Change of CTA tapped")
            break
        case 3  : //poaster101
            visitPoaster101()
            Mixpanel.mainInstance().track(event: "Settings - Poaster 101 tapped")
            break
        case 4  : //poaster101
            visitStripeLogin()
            Mixpanel.mainInstance().track(event: "Settings - Stripe login opened")
            break
        case 5  : //sign out
            signOutBtnClicked()
            Mixpanel.mainInstance().track(event: "Signed out")
            break

        default :
            break
        }
    }
    
}
