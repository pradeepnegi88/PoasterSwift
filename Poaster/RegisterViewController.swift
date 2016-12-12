//
//  RegisterViewController.swift
//  poaster
//
//  Created by Vinod Sobale on 12/29/15.
//  Copyright © 2015 Vinod Sobale. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class RegisterViewController: UIViewController {
    
    let prefs = NSUserDefaults.standardUserDefaults()
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var signUpButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        activityIndicator.hidden = true

        customTextFieldFont()
        
        // Sign up button
        Utilities.CustomButton(signUpButton, BGCOLOR: "#D35746", BORDERCOLOR: "#D35746", TITLECOLOR: nil, CornerRadius: 4, BorderWidth: 0, FontName: "ProximaNova-Regular", FontSize: 18)
        
        // Utilities.CustomUITextField(firstNameField)
        // Utilities.CustomUITextField(lastNameField)
        // Utilities.CustomUITextField(emailField)
        // Utilities.CustomUITextField(passwordField)
    }
    
    func customTextFieldFont() {
        let font = UIFont(name: "ProximaNova-Regular", size: 18)!
        let attributes = [
            NSForegroundColorAttributeName: UIColor.lightGrayColor(),
            NSFontAttributeName : font]
        
        firstNameField.attributedPlaceholder = NSAttributedString(string: "First Name",
                                                                  attributes:attributes)
        lastNameField.attributedPlaceholder = NSAttributedString(string: "Last Name",
                                                                 attributes:attributes)
        emailField.attributedPlaceholder = NSAttributedString(string: "Email Address",
                                                              attributes:attributes)
        passwordField.attributedPlaceholder = NSAttributedString(string: "Password",
                                                                 attributes:attributes)
    }
    
    // MARK : Dismissing Keyboard functions
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    @IBAction func dismissRegisterModal(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    @IBAction func registrer(sender: UIButton) {
        
        let first_name = String(UTF8String: firstNameField.text!)!
        let last_name = String(UTF8String: lastNameField.text!)!
        let email = String(UTF8String: emailField.text!)!
        let password = String(UTF8String: passwordField.text!)!
        
        if isDataValid(){
            
            activityIndicator.hidden = false
            activityIndicator.startAnimating()
            
            let hosturl = "\(HOST)/api/v1/user/signup.json"
            
            Alamofire.request(.POST, hosturl,
                parameters: ["user": ["first_name": first_name, "last_name": last_name, "email": email, "password": password]], encoding: .JSON)
                .responseJSON {
                    response in debugPrint(response)     // prints detailed description of all response properties
                    
                    
                    if let value = response.result.value {
                        let json = JSON(value)
                        
                        if json["success"] == true {
                            if let StepNumber = json["data"]["step"].int {
                                self.prefs.setValue(StepNumber, forKey: "step_number")
                            }
                            
                            let authtoken = String(json["data"]["auth_token"])
                            let registration_complete  = Bool(json["data"]["registration_completed"])
                            
                            self.prefs.setValue(authtoken, forKey: "authtoken")
                            
                            self.prefs.setValue(registration_complete, forKey: "registration_completed")
                            
                            self.performSegueWithIdentifier("FreeTrialSegue", sender: nil)
                            
                        } else {
                            let error = String(json["errors"])
                            self.displayAlertMessage(error)
                            self.activityIndicator.hidden = true
                            self.activityIndicator.startAnimating()
                        }
                    } // saving response in // let value
            }// Alamofire request
        }
        else {
            var message :String = "Please enter valid details"
            if passwordField.text != "" && passwordField.text?.utf16.count < 8 {
                message = "Password must be greater than 7 Characters"
            }
            let alertView = UIAlertController(title: "Error", message: message, preferredStyle: .Alert);
            alertView.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil));
            presentViewController(alertView, animated: true, completion: nil)
        }
        
    }
    
    func displayAlertMessage(message: String) {
        let alertView = UIAlertController(title: "Error", message: message, preferredStyle: .Alert);
        alertView.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil));
        presentViewController(alertView, animated: true, completion: nil)
    }
    
    func isDataValid()->Bool {
        if firstNameField.text == "" && passwordField.text == "" && emailField.text == "" && passwordField.text == "" || passwordField.text?.utf16.count < 8
        {
            return false;
        }
        return true;
    }
    
}
