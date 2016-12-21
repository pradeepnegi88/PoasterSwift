//
//  LoginViewController.swift
//  poaster
//
//  Created by Vinod Sobale on 12/26/15.
//  Copyright © 2015 Vinod Sobale. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ViewController: UIViewController {
    
    let prefs = NSUserDefaults.standardUserDefaults()
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var emailField: UITextField!
    
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        activityIndicator.hidden = true
        
        // Login Button
        Utilities.CustomButton(loginButton, BGCOLOR: PRIMARY_BUTTON_BG_COLOR, BORDERCOLOR: PRIMARY_BUTTON_BG_COLOR, TITLECOLOR: nil, CornerRadius: 4, BorderWidth: 0, FontName: "ProximaNova-Regular", FontSize: 18)
        
        // Utilities.CustomUITextField(emailField)
        // Utilities.CustomUITextField(passwordField)
        
        customTextFieldFont()
        
    }
    
    func customTextFieldFont() {
        let font = UIFont(name: "ProximaNova-Regular", size: 18)!
        let attributes = [
            NSForegroundColorAttributeName: UIColor.lightGrayColor(),
            NSFontAttributeName : font]
        
        emailField.attributedPlaceholder = NSAttributedString(string: "Email Address",
            attributes:attributes)
        passwordField.attributedPlaceholder = NSAttributedString(string: "Password",
            attributes:attributes)
    }
    
    @IBAction func dismissModal(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func login(sender: UIButton) {
        
        let email = String(UTF8String: emailField.text!)!
        let password = String(UTF8String: passwordField.text!)!
        
        if isDataValid()
        {
            activityIndicator.hidden = false
            activityIndicator.startAnimating()

            let hosturl = "\(HOST)/api/v1/user/login.json"
            
            Alamofire.request(.POST, hosturl,
                parameters: ["user": ["email": email, "password": password]], encoding: .JSON)
                .responseJSON {
                    response in debugPrint(response)     // prints detailed description of all response properties
                    let value = response.result.value
                    
                    let json = JSON(value!)
                    
                    if json["success"] == true {
                        
                        let authtoken = json["data"]["auth_token"]

                        let auth_token = String(authtoken);
                        self.prefs.setValue(auth_token, forKey: "authtoken")
                        
                        let reg_complete_Flag = Bool(json["data"]["registration_completed"])
                        self.prefs.setValue(reg_complete_Flag, forKey: "registration_completed")
                        
                        self.performSegueWithIdentifier("CameraView", sender: nil)
                        
                        self.activityIndicator.hidden = true
                        self.activityIndicator.startAnimating()
                    } else {
                        let errorMessage = String(json["errors"])
                        let alert = UIAlertController(title: "Oops!", message: errorMessage, preferredStyle: UIAlertControllerStyle.Alert)
                        let okButton = UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Cancel, handler: nil)
                        alert.addAction(okButton)
                        self.presentViewController(alert, animated: true, completion: nil)
                        self.activityIndicator.hidden = true
                        self.activityIndicator.startAnimating()
                    }
            }
        } // Checking if email and password are provided
        else
        {
            let message :String = "Please enter Email and Password"
            let alertView = UIAlertController(title: "Error", message: message, preferredStyle: .Alert);
            alertView.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil));
            
            presentViewController(alertView, animated: true, completion: nil)
        }
    }
    
    func isDataValid()->Bool {
       if emailField.text == "" || passwordField.text == "" {
            return false;
        }
        return true;
    }
    
}

