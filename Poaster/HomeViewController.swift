//
//  HomeViewController.swift
//  poaster
//
//  Created by Vinod Sobale on 12/29/15.
//  Copyright © 2015 Vinod Sobale. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import FBSDKCoreKit
import FBSDKLoginKit
import BXProgressHUD
import Mixpanel

class HomeViewController: UIViewController {
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var FooField: UITextField!
    
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var SignUpWithFacebookButton: UIButton!

    
    
    let prefs = NSUserDefaults.standardUserDefaults()
    let login: FBSDKLoginManager = FBSDKLoginManager()
    let PoasterDelegate = UIApplication.sharedApplication().delegate! as! AppDelegate
    var progressHud = BXProgressHUD()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Utilities.CustomUITextField(FooField)
        
        // Facebook Button
        Utilities.CustomButton(SignUpWithFacebookButton, BGCOLOR: "#3B5998", BORDERCOLOR: nil, TITLECOLOR: "#FFFFFF", CornerRadius: 4, BorderWidth: 0, FontName: "ProximaNova-Regular", FontSize: 16)
        
        // Login Button
        Utilities.CustomButton(loginButton, BGCOLOR: "#D35746", BORDERCOLOR: "#D35746", TITLECOLOR: nil, CornerRadius: 4, BorderWidth: 0, FontName: "ProximaNova-Regular", FontSize: 18)
        
        CustomRegisterButton()
        
        view.addSubview(progressHud)
    }
    
    func CustomRegisterButton () {
        registerButton.backgroundColor = UIColor.clearColor()
        registerButton.layer.cornerRadius = 5
        registerButton.layer.borderWidth = 1
        registerButton.titleLabel!.font =  UIFont(name: "ProximaNova-Regular", size: 18)
        registerButton.layer.borderColor = UIColor(red: 211/255, green: 87/255, blue: 70/255, alpha: 1.0).CGColor
        registerButton.setTitleColor(UIColor(red: 211/255, green: 87/255, blue: 70/255, alpha: 1.0), forState: UIControlState.Normal)
    }
    
    
    @IBAction func LoginWithFacebook(sender: UIButton) {
        
        Mixpanel.mainInstance().track(event: "Facebook login selected")
        
        if FBSDKAccessToken.currentAccessToken() != nil {
            print("wont go to Facebook")
            self.progressHud.show()
            GrabPersonalDetails(FBSDKAccessToken.currentAccessToken().tokenString)
            
        } else {
            print("Go to Facebook.com and get a token")
            // Go to Facebook.com and get a token
            
            login.loginBehavior = FBSDKLoginBehavior.Browser
            login.logInWithReadPermissions(["public_profile", "email"], fromViewController: self) { (result: FBSDKLoginManagerLoginResult!, error) -> Void in
                if (error != nil) {
                    NSLog("Process error")
                    print(error)
                }
                else if result.isCancelled {
                    NSLog("Cancelled")
                }
                else {
                    NSLog("Logged in")
                    // After successfull login save that Access token and other details in store API
                    if result.grantedPermissions.contains("email") {
                        print(FBSDKAccessToken.currentAccessToken().tokenString)
                        self.GrabPersonalDetails(FBSDKAccessToken.currentAccessToken().tokenString)
                    }
                    Mixpanel.mainInstance().track(event: "Successfully logged in with FaceBook")
                }// logged in
            }
        } // If FBAccessToken exists
    }// LoginWithFacebook IBAction
    
    func GrabPersonalDetails(AccessToken: String) {
        FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"email,first_name, last_name"]) .startWithCompletionHandler({ (connection:FBSDKGraphRequestConnection!, result:AnyObject!, error:NSError!) -> Void in
            print(result)
            let userID: NSString = result.valueForKey("id") as! String
            let first_name:   NSString = result.valueForKey("first_name") as! String
            let last_name:   NSString = result.valueForKey("last_name") as! String
            let email:  NSString = result.valueForKey("email") as! String

            self.StoreFacebook(email as String, UID: userID as String, accesstoken: AccessToken, firstname: first_name as String, lastname: last_name as String)
        })
    }
    
    func StoreFacebook(useremail: String, UID: String, accesstoken: String, firstname: String, lastname: String) {
        
        let hosturl = "\(HOST)/api/v1/user/facebook.json"
        
        self.progressHud.show()
        
        Alamofire.request(.POST, hosturl,
            parameters: ["email": useremail, "uid": UID, "provider": "facebook", "oauth_token": accesstoken, "first_name": firstname, "last_name": lastname], encoding: .JSON)
            .responseJSON {
                response in debugPrint(response)
                // prints detailed description of all response properties
                print(response.result.value)
                if let value = response.result.value {
                    let json = JSON(value)
                    if json["success"] == true {
                        print("SuccessFul")
                        
                        let registration_complete = Bool(json["data"]["registration_completed"])
                        let authtoken = String(json["data"]["auth_token"])
                        
                        self.prefs.setValue(authtoken, forKey: "authtoken")
                        self.prefs.setValue(registration_complete, forKey: "registration_completed")
                        
                        let step = json["data"]["step"].int
                        
                        print("reg status\(registration_complete)")
                        
                        if registration_complete {
                            self.PoasterDelegate.window?.rootViewController = self.storyboard!.instantiateViewControllerWithIdentifier("loginNavigationVC") as! UINavigationController
                        } else {
                            if step == 1 {
                                self.performSegueWithIdentifier("IntroSegue", sender: nil)
                            } else {
                                self.performSegueWithIdentifier("IntroSegue", sender: nil)
                            }
                        }
                        
                    }
                } // saving response in // let value
        }// Alamofire request
    }
}
