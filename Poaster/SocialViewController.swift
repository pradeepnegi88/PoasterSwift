//
//  SocialViewController.swift
//  poaster
//
//  Created by Poaster on 1/26/16.
//  Copyright © 2016 Poaster. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import FBSDKCoreKit
import FBSDKLoginKit
import TwitterKit
import Mixpanel

protocol SocialViewSelectionDelegate {
    func MakeFaceBookInactive ()
}

var socialViewSelectionDelegate: SocialViewSelectionDelegate?

class SocialViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, SocialViewSelectionDelegate {
    
    let prefs = NSUserDefaults.standardUserDefaults()
    
    var daysData = ["1 Day", "2 Days", "3 Days"]
    var durationNumber: Int! = nil
    var PreviewPoastPoastID: Int! = nil
    var providersArr = [String]()
    var foo: Bool! = nil
    
    let login: FBSDKLoginManager = FBSDKLoginManager()
    
    let FacebookImage: UIImage = UIImage(named: "FacebookIcon")!
    let FacebookSelectedImage: UIImage = UIImage(named: "FacebookIconSelected")!
    
    let TwitterImage: UIImage = UIImage(named: "TwitterIcon")!
    let TwitterSelectedImage: UIImage = UIImage(named: "TwitterIconSelected")!
    
    let PinterestImage: UIImage = UIImage(named: "PinterestIcon")!
    let PinterestSelectedImage: UIImage = UIImage(named: "PinterestIconSelected")!
    
    @IBOutlet weak var FacebookButton: UIButton!
    @IBOutlet weak var TwitterButton: UIButton!
    @IBOutlet weak var poastButton: UIButton!
    @IBOutlet weak var ExpiryPicker: UIPickerView!
    @IBOutlet weak var poastedView: UIView!
    @IBOutlet weak var TopLabel: UILabel!
    @IBOutlet weak var PoastExpiryLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        durationNumber = 1
        socialViewSelectionDelegate = self
        
        TopLabel.font = UIFont(name: "ProximaNova-Regular", size: 17.0)
        PoastExpiryLabel.font = UIFont(name: "ProximaNova-Regular", size: 17.0)
        
        FacebookButton.setImage(FacebookImage, forState: UIControlState.Normal)
        FacebookButton.setImage(FacebookSelectedImage, forState: UIControlState.Selected)
        
        TwitterButton.setImage(TwitterImage, forState: UIControlState.Normal)
        TwitterButton.setImage(TwitterSelectedImage, forState: UIControlState.Selected)
        
        FacebookButton.addTarget(self, action: #selector(SocialViewController.PoastToFacebook(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        let logoImage:UIImage = UIImage(named: "camera-logo.png")!
        self.navigationItem.titleView = UIImageView(image: logoImage)
        
        self.ExpiryPicker.delegate = self
        self.ExpiryPicker.dataSource = self
        
        if let label = PoasterUtility.sharedInstance.getUserDefaultValueForKey(K_POAST_ID) as Int? {
            PreviewPoastPoastID = label;
        }
        
        // Poast Button
        Utilities.CustomButton(poastButton, BGCOLOR: "#98C940", BORDERCOLOR: nil, TITLECOLOR: nil, CornerRadius: 4, BorderWidth: 0, FontName: "ProximaNova-Regular", FontSize: 18)
        
        
        displayPoastButton()
        
        // Hiding Post success view
        poastedView.alpha = 0.0
        poastedView.layer.zPosition = 2;
        
        self.navigationController?.navigationBar.backItem?.title = "BACK"
    }
    
    @IBAction func TwitterAction(sender: UIButton) {
        Mixpanel.mainInstance().track(event: "Social icon tapped",
                                      properties: ["Social Network" : "Twitter"])
        sender.selected = !sender.selected;
        if sender.selected {
            providersArr.append("twitter")
            print(providersArr)
            LoginWithTwitter()
            
        } else {
            if providersArr.contains("twitter") {
                if let index = providersArr.indexOf("twitter") {
                    providersArr.removeAtIndex(index)
                    print(providersArr)
                }
            }
        }
    }
    
    func MakeFaceBookInactive() {
        print("making it inactive")
        if providersArr.contains("facebook") {
            if let index = providersArr.indexOf("facebook") {
                FacebookButton.selected = false
                providersArr.removeAtIndex(index)
            }
        }
    }
    
    func PoastToFacebook(sender:UIButton) {
        if FBSDKAccessToken.currentAccessToken() != nil {
            
            let permissions = FBSDKAccessToken.currentAccessToken().permissions
            
            if permissions.contains("manage_pages") && permissions.contains("publish_actions") && permissions.contains("publish_pages") {
                print("Got publishing permissions")
                print(FBSDKAccessToken.currentAccessToken().tokenString)
                StoreToken()
                sender.selected = !sender.selected;
                if sender.selected {
                    providersArr.append("facebook")
                    Mixpanel.mainInstance().track(event: "Social icon tapped",
                                                  properties: ["Social Network" : "Facebook"])
                    performSegueWithIdentifier("FBPagesSegue", sender: nil)
                } else {
                    if providersArr.contains("facebook") {
                        if let index = providersArr.indexOf("facebook") {
                            providersArr.removeAtIndex(index)
                            Mixpanel.mainInstance().track(event: "Facebook avoided")
                        }
                    }
                }
            } else {
                print("No publishing permissions")
                GetPublishingPermissions()
            }
        } else {
            GetPublishingPermissions()
        }
    } // PoastToFacebook
    
    func GetPublishingPermissions() {
        login.loginBehavior = FBSDKLoginBehavior.Browser
        login.logInWithPublishPermissions(["publish_actions", "manage_pages", "publish_pages"], fromViewController: self) { (result: FBSDKLoginManagerLoginResult!, error) -> Void in
            if (error != nil) {
                NSLog("Process error")
                print(error)
            }
            else if result.isCancelled {
                NSLog("Cancelled")
            }
            else {
                NSLog("Got publishing permissions and new token")
                
                print(FBSDKAccessToken.currentAccessToken().tokenString)
                self.StoreToken()
            }
        }
    }
    
    func StoreToken() {
        if (FBSDKAccessToken.currentAccessToken() != nil) {
            let uid = FBSDKAccessToken.currentAccessToken().userID
            let AccessToken = FBSDKAccessToken.currentAccessToken().tokenString
            let ExpirationDate = FBSDKAccessToken.currentAccessToken().expirationDate
            let ExDate = String(ExpirationDate)
            print("Got the token")
            
            if uid != nil && AccessToken != nil && ExpirationDate != nil {
                if let authtoken = prefs.stringForKey("authtoken"){
                    
                    let hosturl = "\(HOST)/api/v1/user/store.json"
                    
                    Alamofire.request(.POST, hosturl,
                        parameters: ["auth_token": authtoken,
                            "providers": ["name": "facebook", "oauth_token": AccessToken, "oauth_expires_at": ExDate, "uid": uid]
                        ], encoding: .JSON)
                        .responseJSON {
                            response in debugPrint(response)
                            // prints detailed description of all response properties
                            print(response.result.value)
                            if let value = response.result.value {
                                let json = JSON(value)
                                if json["success"] == true {
                                    print("SuccessFul")
                                    self.displayPoastButton()
                                } else {
                                    print("UnsuccessFul")
                                }
                            } // saving response in // let value
                    }// Alamofire request
                }
            }
        }
    } // StoreToken
    
    func displayPoastButton() {
        if providersArr.count < 1 {
            poastButton.enabled = false
            poastButton.alpha = 0.5
        } else {
            poastButton.enabled = true
            poastButton.alpha = 1.0
        }
    } // displayPoastButton
    
    func redirectToCameraView() {
        // redirect to camera view
        print("Redirected to camera view")
        let SecondVC = self.storyboard?.instantiateViewControllerWithIdentifier("CameraStoryBoardID") as! SecondViewController
        self.navigationController!.pushViewController(SecondVC, animated: true)
    }
    
    func setExpiryforPoast() {
        if let authtoken = prefs.stringForKey("authtoken"){
            // self.createOverlay("Poasting...")
            
            let hosturl = "\(HOST)/api/v1/user/set_post_expiry.json"
            
            print("making request to set expiry of the poast now")
            
            Alamofire.request(.POST, hosturl,
                parameters: ["auth_token": authtoken, "poast": ["poast_id": PreviewPoastPoastID, "expires_in": durationNumber]
                ], encoding: .JSON)
                .responseJSON {
                    response in debugPrint(response)
                    print(response.result.value)
                    if let value = response.result.value {
                        let json = JSON(value)
                        if json["success"] == true {
                            print("SuccessFul. Set the expriry of the paost to \(self.durationNumber)")
                        } else {
                            print("UnsuccessFul")
                        }
                    } // saving response in // let value
            }// Alamofire request
        }
    }
    
    func LoginWithTwitter() {
        
        poastButton.enabled = false
        poastButton.alpha = 0.5
        
        Twitter.sharedInstance().logInWithCompletion {
            (session, error) -> Void in
            if (session != nil) {
                
                let OAuthToken = session!.authToken
                let OAuthSecret = session!.authTokenSecret
                print(OAuthToken)
                print(OAuthSecret)
                
                if let authtoken = self.prefs.stringForKey("authtoken"){
                    
                    let hosturl = "\(HOST)/api/v1/user/store.json"
                    
                    Alamofire.request(.POST, hosturl,
                        parameters: ["auth_token": authtoken,
                            "providers": ["name": "twitter", "oauth_token": OAuthToken, "oauth_secret": OAuthSecret, "uid": "", "oauth_expires_at": ""]
                        ], encoding: .JSON)
                        .responseJSON {
                            response in debugPrint(response)
                            // prints detailed description of all response properties
                            print(response.result.value)
                            if let value = response.result.value {
                                let json = JSON(value)
                                if json["success"] == true {
                                    print("SuccessFul")
                                    self.displayPoastButton()
                                } else {
                                    print("UnsuccessFul")
                                    if self.providersArr.count >= 1 {
                                        self.displayPoastButton()
                                    }
                                }
                            } // saving response in // let value
                    }// Alamofire request
                }
                
            } else {
                print(error?.localizedDescription);
            }
        }
    }// LoginWithTwitter
    
    @IBAction func PoastToSocialMedia(sender: UIButton) {
        
        Mixpanel.mainInstance().track(event: "Poast button tapped")
        
        if let authtoken = prefs.stringForKey("authtoken"){
            
            let hosturl = "\(HOST)/api/v1/user/poasts/\(PreviewPoastPoastID)/share.json"
            
            // Showing Poasted screen first
            self.navigationController?.setNavigationBarHidden(true, animated: true)
            self.navigationController?.toolbarHidden = true
            UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                self.poastedView.alpha = 1.0
            }) { (Bool) -> Void in
                print("done")
                NSTimer.scheduledTimerWithTimeInterval(1.5, target:self, selector: #selector(SocialViewController.redirectToCameraView), userInfo: nil, repeats: false)
            }
            
            Alamofire.request(.POST, hosturl,
                parameters: ["auth_token": authtoken, "id": PreviewPoastPoastID, "providers": providersArr], encoding: .JSON)
                .responseJSON {
                    response in debugPrint(response)
                    // prints detailed description of all response properties
                    print(response.result.value)
                    if let value = response.result.value {
                        let json = JSON(value)
                        if json["success"] == true {
                            print("SuccessFul")
                            Mixpanel.mainInstance().track(event: "Successfully Poasted")
                            self.setExpiryforPoast()
                        } else {
                            print("UnsuccessFul")
                        }
                    } // saving response in // let value
            }// Alamofire request
        }
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return daysData.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return daysData[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if daysData[row] == "1 Day" {
            durationNumber = 1
            print(durationNumber)
        } else if daysData[row] == "2 Days" {
            durationNumber = 2
            print(durationNumber)
        } else {
            durationNumber = 3
            print(durationNumber)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "FBPagesSegue") {
            let PagesVC = (segue.destinationViewController as! PagesViewController)
            PagesVC.PoastID = PreviewPoastPoastID
        }
    }
    
}
