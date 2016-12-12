//
//  ResetPasswordViewController.swift
//  Poaster
//
//  Created by Vinod Sobale on 6/20/16.
//  Copyright © 2016 Poaster LLC. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ResetPasswordViewController: UIViewController {
    
    let prefs = NSUserDefaults.standardUserDefaults()
    
    var FinalToken: String! = nil
    
    @IBOutlet weak var PasswordField: UITextField!
    @IBOutlet weak var AnotherPasswordField: UITextField!
    @IBOutlet weak var SetPasswordbtn: UIButton!
    @IBOutlet weak var Indicator: UIActivityIndicatorView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Indicator.hidden = true
        
        Utilities.CustomButton(SetPasswordbtn, BGCOLOR: "#D35746", BORDERCOLOR: "#D35746", TITLECOLOR: nil, CornerRadius: 4, BorderWidth: 0, FontName: "ProximaNova-Regular", FontSize: 18)
    
        Utilities.CustomUITextField(PasswordField)
        Utilities.CustomUITextField(AnotherPasswordField)
    }
    
    func displayAlertMessage(message: String) {
        let alertView = UIAlertController(title: "Error", message: message, preferredStyle: .Alert);
        alertView.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil));
        presentViewController(alertView, animated: true, completion: nil)
    }
    
    func isEmpty() -> Bool {
        if PasswordField.text == "" || AnotherPasswordField.text == "" {
            return false
        }
        return true;
    }
    
    func PasswordsMatch() -> Bool {
        if PasswordField.text != AnotherPasswordField.text  {
            return false
        }
        return true;
    }
    
    @IBAction func SetPassword(sender: UIButton) {
        
        Indicator.hidden = false
        Indicator.startAnimating()
        
        let new_password = String(UTF8String: PasswordField.text!)!
        let confirmed_password = String(UTF8String: AnotherPasswordField.text!)!
        
        if isEmpty() {
            if PasswordsMatch() {
                if let FinalToken = self.prefs.stringForKey("reset_password_token") {
                    Alamofire.request(.PUT, "\(HOST)/api/v1/user/reset_password.json",
                        parameters: ["user": ["reset_password_token": FinalToken, "password": new_password, "password_confirmation": confirmed_password]], encoding: .JSON)
                        .responseJSON {
                            response in debugPrint(response)     // prints detailed description of all response properties
                            if let value = response.result.value {
                                let json = JSON(value)
                                if json["success"] == true {
                                    print("Successful")
                                    self.Indicator.hidden = true
                                    self.Indicator.startAnimating()
                                    
                                    let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                                    
                                    let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                                    let HomeVC = mainStoryboard.instantiateViewControllerWithIdentifier("initialVC") as! HomeViewController
                                    
                                    appdelegate.window!.rootViewController = HomeVC
                                    
                                } else {
                                    print("Unsuccessful")
                                    self.Indicator.hidden = true
                                    self.Indicator.startAnimating()
                                }
                            } // saving response in // let value
                    }// Alamofire request
                }
            } else {
                displayAlertMessage("Passwords need to match")
                Indicator.hidden = true
                Indicator.startAnimating()
            }
        } else {
            displayAlertMessage("Please enter your password")
            Indicator.hidden = true
            Indicator.startAnimating()
        }
    }
    
    
}
