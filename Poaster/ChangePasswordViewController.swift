//
//  ChangePasswordViewController.swift
//  poaster
//
//  Created by Vinod Sobale on 12/03/16.
//  Copyright © 2016 Vinod Sobale. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ChangePasswordViewController: UIViewController {
    
    @IBOutlet weak var newPasswordField: UITextField!
    
    @IBOutlet weak var confirmPasswordField: UITextField!
    
    @IBOutlet weak var changePasswordBtn: UIButton!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Utilities.CustomButton(changePasswordBtn, BGCOLOR: "#D35746", BORDERCOLOR: "#D35746", TITLECOLOR: nil, CornerRadius: 4, BorderWidth: 0, FontName: "ProximaNova-Regular", FontSize: 18)

        customTextFieldFont()
        
        Utilities.CustomUITextField(newPasswordField)
        Utilities.CustomUITextField(confirmPasswordField)
        
        indicator.hidden = true
    }
    
    @IBAction func dismissChangePasswordScreen(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func customTextFieldFont() {
        let font = UIFont(name: "ProximaNova-Regular", size: 18)!
        let attributes = [
            NSForegroundColorAttributeName: UIColor.lightGrayColor(),
            NSFontAttributeName : font]
        
        newPasswordField.attributedPlaceholder = NSAttributedString(string: "New Password",
            attributes:attributes)
        confirmPasswordField.attributedPlaceholder = NSAttributedString(string: "Confirm New Password",
            attributes:attributes)
    }
    
    @IBAction func ChangePassword(sender: UIButton) {
        
        indicator.hidden = false
        indicator.startAnimating()
        
        let new_password = String(UTF8String: newPasswordField.text!)!
        let confirmed_password = String(UTF8String: confirmPasswordField.text!)!
        
        let prefs = NSUserDefaults.standardUserDefaults()
        if let AToken = prefs.stringForKey("authtoken"){
            print("Token \(AToken)")
            
            if newPasswordField.text != "" || confirmPasswordField.text != ""  {
                if new_password == confirmed_password {
                    Alamofire.request(.POST, "\(HOST)/api/v1/user/change_password.json?auth_token=\(AToken)&user[password]=\(new_password)", encoding: .JSON)
                        .responseJSON {
                            response in debugPrint(response)     // prints detailed description of all response properties
                            
                            if let value = response.result.value {
                                let json = JSON(value)
                                
                                if json["success"] == true {
                                    print(json)
                                    print("Successful")
                                    self.dismissViewControllerAnimated(true, completion: nil)
                                    self.indicator.hidden = true
                                    self.indicator.startAnimating()
                                } else {
                                    print("Unsuccessful")
                                    self.indicator.hidden = true
                                    self.indicator.startAnimating()
                                }
                            } // saving response in // let value
                    }// Alamofire request
                } else {
                    let message :String = "Passwords don't match"
                    let alertView = UIAlertController(title: "Error", message: message, preferredStyle: .Alert);
                    alertView.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil));
                    presentViewController(alertView, animated: true, completion: nil)
                    self.indicator.hidden = true
                    self.indicator.startAnimating()
                }// if (see if both passwords match)
            } else {
                self.indicator.hidden = true
                self.indicator.startAnimating()
            }
        }
    }
}
