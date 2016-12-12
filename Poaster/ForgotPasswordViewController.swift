//
//  ForgotPasswordViewController.swift
//  poaster
//
//  Created by Vinod Sobale on 5/3/16.
//  Copyright © 2016 Vinod Sobale. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ForgotPasswordViewController: UIViewController {
    
    @IBOutlet weak var EmailField: UITextField!
    @IBOutlet weak var ForgotPasswordBtn: UIButton!
    @IBOutlet weak var ActivityIndicator: UIActivityIndicatorView!

    let prefs = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prefs.setValue("", forKey: "reset_password_token")
        
        ActivityIndicator.hidden = true
        
        Utilities.CustomButton(ForgotPasswordBtn, BGCOLOR: "#D35746", BORDERCOLOR: "#D35746", TITLECOLOR: nil, CornerRadius: 4, BorderWidth: 0, FontName: "ProximaNova-Regular", FontSize: 18)
        
        Utilities.CustomUITextField(EmailField)
    }
    
    func isValidEmail(testStr:String) -> Bool {
        // print("validate calendar: \(testStr)")
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(testStr)
    }
    
    @IBAction func DismissForgotPassword(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func displayAlertMessage(message: String) {
        let alertView = UIAlertController(title: "Oops", message: message, preferredStyle: .Alert);
        alertView.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil));
        presentViewController(alertView, animated: true, completion: nil)
    }
    
    
    @IBAction func SendForgottenPassword(sender: UIButton) {
        ActivityIndicator.hidden = false
        ActivityIndicator.startAnimating()

        let Email = EmailField.text!
        let hosturl = "\(HOST)/api/v1/user/forgot_password.json?user[email]=\(Email)"
        
        if isValidEmail(Email) && Email != "" {
            Alamofire.request(.POST, hosturl, encoding: .JSON)
                .responseJSON {
                    response in debugPrint(response)     // prints detailed description of all response properties
                    if let value = response.result.value {
                        let json = JSON(value)
                        print(json)
                        if json["success"] == true {
                            self.ActivityIndicator.hidden = true
                            self.ActivityIndicator.startAnimating()
                            
                            let alert = UIAlertController(title: "Success", message: "We sent an email to the address you provided", preferredStyle: .Alert)
                            let firstAction = UIAlertAction(title: "OK", style: .Default) { (alert: UIAlertAction!) -> Void in
                                
                                // Dissmis the controller
                                print("API Call Successful!")
                                self.prefs.setValue(String(json["data"]["reset_password_token"]), forKey: "reset_password_token")
                                self.dismissViewControllerAnimated(true, completion: nil)
                            }

                            alert.addAction(firstAction)
                            self.presentViewController(alert, animated: true, completion:nil)
                            
                        } else {
                            let error = String(json["errors"])
                            if error != "" {
                                self.displayAlertMessage(error)
                            }
                            self.ActivityIndicator.hidden = true
                            self.ActivityIndicator.startAnimating()
                            print("API Call Failed!")
                        }
                    } // saving response in // let value
            }// Alamofire request
        } else {
            displayAlertMessage("Please enter valid email")
            self.ActivityIndicator.hidden = true
            self.ActivityIndicator.startAnimating()
        }
    } // SendForgottenPassword
    
}