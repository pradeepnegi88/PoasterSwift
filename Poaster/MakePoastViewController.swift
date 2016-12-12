//
//  MakePoastViewController.swift
//  poaster
//
//  Created by Vinod Sobale on 1/3/16.
//  Copyright © 2016 Vinod Sobale. All rights reserved.
//

import UIKit
import Toucan
import SwiftyJSON
import Alamofire

class MakePoastViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate {
    
    let prefs = NSUserDefaults.standardUserDefaults()
    
    @IBOutlet weak var croppedImage: UIImageView!
    
    @IBOutlet weak var PoastTitle: UITextView!
    @IBOutlet weak var PoastDescription: UITextView!
    
    
    @IBOutlet weak var titleCountLbl: UILabel!
    @IBOutlet weak var descCountLbl: UILabel!
    @IBOutlet weak var TitleLabel: UILabel!
    @IBOutlet weak var DescriptionLabel: UILabel!
    @IBOutlet weak var OnePaySwitch: UISwitch!
    @IBOutlet weak var OnePayView: UIView!
    @IBOutlet weak var CostField: UITextField!
    @IBOutlet weak var QuantityField: UITextField!
    
    var titleCharacterCount: Int! = 45
    var descCharacterCount: Int! = 90
    
    var base64String: String! = nil
    
    var receivedImage: UIImage? = nil
    
    var callToActionName: String! = nil
    
    var AlternateAction: String! = nil
    
    var DefaultAction: String! = nil
    
    var ActionPhoneNumber: String? = nil
    
    var BusinessName: String? = nil
    
    let titlePlaceHolertring: String! = "Limited time (‘Today Only’): limited availability (‘Only 5 left’): limited discount (‘First 10’)"
    
    let descPlaceHolerString: String! = ""
    
    @IBOutlet weak var Scroller: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SendBusinessName()
        
        OnePaySwitch.on = false
        OnePayView.hidden = true
        
        QuantityField.delegate = self
        CostField.delegate = self
        
        titleCountLbl.text = String(titleCharacterCount)
        descCountLbl.text = String(descCharacterCount)
        
        let resizedImage = Toucan(image: receivedImage!).resize(CGSize(width: 320, height: 333), fitMode: Toucan.Resize.FitMode.Crop).image
        
        let imageData = UIImageJPEGRepresentation(resizedImage, 0.5)
        
        base64String = imageData!.base64EncodedStringWithOptions([])
        
        // Adding cournded corners to the image view
        croppedImage.layer.cornerRadius = CGRectGetWidth(croppedImage.frame)/26.0
        croppedImage.clipsToBounds = true
        
        croppedImage.image = receivedImage
        
        SwitchStatus()
        customTextView()
        getCTARequest()
        
        PoastTitle.delegate = self
        PoastDescription.delegate = self
        PoastTitle.text = titlePlaceHolertring
        PoastTitle.textColor = UIColor.lightGrayColor()
        PoastDescription.textColor = UIColor.lightGrayColor()
        
        self.navigationController!.navigationBar.tintColor = UIColor(red: 152/256, green: 201/256, blue: 64/256, alpha: 1.0)
        
        let logoImage:UIImage = UIImage(named: "camera-logo.png")!
        self.navigationItem.titleView = UIImageView(image: logoImage)
        
        // Changing the case of the Back link
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "BACK", style: .Plain, target: nil, action: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        let logButton : UIBarButtonItem = UIBarButtonItem(title: "PREVIEW", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(MakePoastViewController.previewPoast))
        self.navigationItem.rightBarButtonItem = logButton
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Making sure Switch status stays updated
        SwitchStatus()
    }
    
    @IBAction func ToggleOnePayView(sender: UISwitch) {
        
        // Getting the most recent info about action and alternate_action
        getCTARequest()
        
        if OnePaySwitch.on {
            OnePayView.hidden = false
            if AlternateAction == "" {
                AlertToSignUpForOnePay()
            }
        } else {
            OnePayView.hidden = true
            
            // If Alternate call to action button has not been set
            // only then go to settings
            if DefaultAction == "" {
                AlertToSetAlternateCTA()
            }
        }
    }
    
    func AlertToSetAlternateCTA() {
        let alert = UIAlertController(title: "Select an Alternate Action Button?", message: "Then you can switch back and forth from the BUY NOW button by simply turning 1Pay on or off as you create new poasts.", preferredStyle: .Alert) // 1
        
        let firstAction = UIAlertAction(title: "YES, GO TO SETTINGS", style: .Default) { (alert: UIAlertAction!) -> Void in
            
            let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let EditDefaultActionVC : EditDefaultActionViewController = storyboard.instantiateViewControllerWithIdentifier("EditDefaultActId") as! EditDefaultActionViewController
            
            let navigationController = UINavigationController(rootViewController: EditDefaultActionVC)
            
            self.presentViewController(navigationController, animated: true, completion: nil)
            
            
        } // 2
        
        let secondAction = UIAlertAction(title: "No", style: .Default) { (alert: UIAlertAction!) -> Void in
            self.OnePaySwitch.on = true
            self.OnePayView.hidden = false
        } // 3
        
        alert.addAction(firstAction)
        alert.addAction(secondAction)
        presentViewController(alert, animated: true, completion:nil)
    }
    
    func AlertToSignUpForOnePay() {
        let alert = UIAlertController(title: "Sign up for Poaster 1Pay?", message: "Then just turn the 1Pay button on or off as you create new Poasts. You can use your default action button or switch to BUY NOW and accept payments right from your newsfeeds.", preferredStyle: .Alert) // 1
        
        let firstAction = UIAlertAction(title: "YES, SIGN ME UP", style: .Default) { (alert: UIAlertAction!) -> Void in
            
            // Take the user to Stripe
            self.CheckIfSignedForOnePay()
            
        }
        
        let secondAction = UIAlertAction(title: "No", style: .Default) { (alert: UIAlertAction!) -> Void in
            self.OnePaySwitch.on = false
        }
        
        alert.addAction(firstAction)
        alert.addAction(secondAction)
        presentViewController(alert, animated: true, completion:nil)
    }
    
    func SwitchStatus() {
        
        if let authtoken = prefs.stringForKey("authtoken"){
            
            let hosturl = "\(HOST)/api/v1/user/seller_stripe_account_info.json?auth_token=\(authtoken)"
            
            Alamofire.request(.GET, hosturl, encoding: .JSON)
                .responseJSON {
                    response in debugPrint(response)
                    // prints detailed description of all response properties
                    // print(response.result.value)
                    if let value = response.result.value {
                        let json = JSON(value)
                        if json["success"] == true {
                            
                            let stripe_account_id = String(json["data"]["stripe_account_id"])
                            
                            if stripe_account_id != "" {
                                self.OnePaySwitch.on = true
                                self.OnePayView.hidden = false
                            } else {
                                self.OnePaySwitch.on = false
                                self.OnePayView.hidden = true
                            }
                            print("SuccessFul")
                        } else {
                            print("UnsuccessFul")
                        }
                    } // saving response in // let value
            }// Alamofire request
        }
    } // SwitchStatus
    
    func CheckIfSignedForOnePay() {
        
        if let authtoken = prefs.stringForKey("authtoken"){
            
            let hosturl = "\(HOST)/api/v1/user/seller_stripe_account_info.json?auth_token=\(authtoken)"
            
            Alamofire.request(.GET, hosturl, encoding: .JSON)
                .responseJSON {
                    response in debugPrint(response)
                    // prints detailed description of all response properties
                    // print(response.result.value)
                    if let value = response.result.value {
                        let json = JSON(value)
                        if json["success"] == true {
                            print("SuccessFul")
                        } else {
                            
                            let StripeSetupVC = self.storyboard?.instantiateViewControllerWithIdentifier("StripeSetupSBView") as! StripeSetupViewController
                            
                            StripeSetupVC.SegueBusinessName = self.BusinessName
                            
                            self.presentViewController(StripeSetupVC, animated: true, completion: nil)
                            
                            print("UnsuccessFul")
                        }
                    } // saving response in // let value
            }// Alamofire request
        }
    }
    
    func SetOnePayFlag(PoastID: Int, OnePayFlag: Bool) {
        
        if let authtoken = prefs.stringForKey("authtoken"){
            Alamofire.request(.POST, "\(HOST)/api/v1/user/set_1pay_deal_flag.json?auth_token=\(authtoken)&poast[id]=\(PoastID)&poast[one_pay_flag]=\(OnePayFlag)", encoding: .JSON)
                .responseJSON {
                    response in debugPrint(response)
                    // prints detailed description of all response properties
                    print(response.result.value)
                    if let value = response.result.value {
                        let json = JSON(value)
                        if json["success"] == true {
                            print("SuccessFul")
                        } else {
                            print("UnsuccessFul")
                        }
                    } // saving response in // let value
            }// Alamofire request
        }
    } // SetOnePayFlag
    
    func getCTARequest() {
        
        if let authtoken = prefs.stringForKey("authtoken"){
            
            let hosturl = "\(HOST)/api/v1/user/get_profile_info.json"
            
            Alamofire.request(.POST, hosturl, parameters: ["auth_token": authtoken], encoding: .JSON)
                .responseJSON {
                    response in debugPrint(response)
                    // prints detailed description of all response properties
                    print(response.result.value)
                    if let value = response.result.value {
                        let json = JSON(value)
                        
                        // Saving Currenct CTA in NSUserDefaults Key 'CTA'
                        
                        if json["success"] == true {
                            print(json)
                            
                            self.DefaultAction = String(json["data"]["business"]["action"])
                            self.AlternateAction = String(json["data"]["business"]["alternate_action"])
                            self.ActionPhoneNumber = String(json["data"]["business"]["phone_number"])
                            
                            self.callToActionName = self.DefaultAction
                            
                            
                            print("SuccessFul")
                        } else {
                            print("UnsuccessFul")
                        }
                    } // saving response in // let value
            }// Alamofire request
        }
    }
    
    func customTextView() {
        PoastTitle.layer.borderColor = UIColor(red:206.0/255, green:206.0/255, blue:206.0/255, alpha:1.0).CGColor
        PoastTitle.layer.borderWidth = 1.0;
        PoastTitle.layer.cornerRadius = 0;
        
        PoastDescription.layer.borderColor = UIColor(red:206.0/255, green:206.0/255, blue:206.0/255, alpha:1.0).CGColor
        PoastDescription.layer.borderWidth = 1.0;
        PoastDescription.layer.cornerRadius = 0;
    }
    
    func SendBusinessName() {
        if let AToken = prefs.stringForKey("authtoken"){
            print("Token \(AToken)")
            
            let hosturl = "\(HOST)/api/v1/user/get_profile_info.json"
            
            Alamofire.request(.POST, hosturl,
                parameters: ["auth_token": AToken], encoding: .JSON)
                .responseJSON {
                    response in debugPrint(response)     // prints detailed description of all response properties
                    if let value = response.result.value {
                        let json = JSON(value)
                        print(json)
                        if json["success"] == true {
                            print("API Call Successful!")
                            self.BusinessName = json["data"]["business"]["business_name"].string
                        } else {
                            print("API Call Failed!")
                        }
                    } // saving response in // let value
            }// Alamofire request
        }
    }
    
    func previewPoast() {
        
        if let authtoken = prefs.stringForKey("authtoken") {
            
            let hosturl = "\(HOST)/api/v1/user/poasts.json"
            
            if OnePaySwitch.on {
                if OnePayFieldsValid() {
                    callToActionName = "appointment"
                    Alamofire.request(.POST, hosturl,
                        parameters: ["auth_token": authtoken,
                            "poast":
                                [
                                    "image": base64String,
                                    "text": PoastTitle.text,
                                    "description": PoastDescription.text,
                                    "quantity": QuantityField.text,
                                    "price": CostField.text
                            ]
                        ], encoding: .JSON)
                        .responseJSON {
                            response in debugPrint(response)
                            // prints detailed description of all response properties
                            print(response.result.value)
                            
                            if let value = response.result.value {
                                let json = JSON(value)
                                
                                let poast_id = json["data"]["id"]
                                let poast_id_integer = String(poast_id)
                                if let final_poast_id = Int(poast_id_integer) {
                                    if json["success"] == true {
                                        
                                        self.SetOnePayFlag(final_poast_id, OnePayFlag: true)
                                        
                                        dispatch_async(dispatch_get_main_queue()) {
                                            PoasterUtility.sharedInstance.setUserDefaultValue(K_POAST_ID, value:final_poast_id)
                                        }
                                    } else {
                                        print("UnsuccessFul")
                                    }
                                }
                                
                            } // saving response in // let value
                    }// Alamofire request
                } else {
                    let message :String = "Please enter 1Pay deal details"
                    
                    let alertView = UIAlertController(title: "Error", message: message, preferredStyle: .Alert);
                    alertView.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil));
                    
                    presentViewController(alertView, animated: true, completion: nil)
                }
            } else {
                if isDataValid() {
                    if DefaultAction == "call_now" {
                        callToActionName = "call_now"
                    } else if DefaultAction == "check_it_out" {
                        callToActionName = "check_it_out"
                    } else {
                        callToActionName = "reservation"
                    }
                    
                    Alamofire.request(.POST, hosturl,
                        parameters: ["auth_token": authtoken,
                            "poast":
                                [
                                    "image": base64String,
                                    "text": PoastTitle.text,
                                    "description": PoastDescription.text
                            ]
                        ], encoding: .JSON)
                        .responseJSON {
                            response in debugPrint(response)
                            // prints detailed description of all response properties
                            print(response.result.value)
                            if let value = response.result.value {
                                let json = JSON(value)
                                let poast_id = json["data"]["id"]
                                
                                let poast_id_integer = (poast_id.stringValue)
                                let final_poast_id = Int(poast_id_integer)
                                
                                if json["success"] == true {
                                    
                                    self.SetOnePayFlag(final_poast_id!, OnePayFlag: false)
                                    
                                    dispatch_async(dispatch_get_main_queue()) {
                                        PoasterUtility.sharedInstance.setUserDefaultValue(K_POAST_ID, value:final_poast_id!)
                                    }
                                    
                                }else {
                                    print("UnsuccessFul")
                                }
                            } // saving response in // let value
                    }// Alamofire request
                } else {
                    let message :String = "Please enter poast details"
                    
                    let alertView = UIAlertController(title: "Error", message: message, preferredStyle: .Alert);
                    alertView.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil));
                    
                    presentViewController(alertView, animated: true, completion: nil)
                }
            }
            
        }
        // Go to next screen directly without waiting poasts.json service response
        let PoastPreviewVC = self.storyboard?.instantiateViewControllerWithIdentifier("PoastPreviewView") as! PoastPreviewViewController
        
        PoastPreviewVC.receivedTitle = self.PoastTitle.text
        PoastPreviewVC.receivedDescription = self.PoastDescription.text
        PoastPreviewVC.receivedPreviewImage = self.croppedImage.image
        PoastPreviewVC.receivedCTAName = self.callToActionName
        PoastPreviewVC.receivedPhoneNumber = self.ActionPhoneNumber
        if OnePaySwitch.on {
            PoastPreviewVC.receivedPrice = CostField.text
            PoastPreviewVC.receivedQuantity = QuantityField.text
        }
        
        self.navigationController!.pushViewController(PoastPreviewVC, animated: true)
        
    } // PreviewPoast function
    
    func isDataValid() -> Bool {
        if PoastTitle.text == "" || PoastTitle.text == titlePlaceHolertring  {
            return false
        }
        return true;
    }
    
    func OnePayFieldsValid() -> Bool {
        if QuantityField.text == "" || CostField.text == "" {
            return false
        }
        return true
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        if PoastTitle.textColor == UIColor.lightGrayColor() {
            PoastTitle.text = nil
            PoastTitle.textColor = UIColor.blackColor()
            
        }
        if PoastDescription.textColor == UIColor.lightGrayColor() {
            PoastDescription.text = nil
            PoastDescription.textColor = UIColor.blackColor()
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if PoastTitle.text.isEmpty {
            PoastTitle.text = titlePlaceHolertring
            PoastTitle.textColor = UIColor.lightGrayColor()
        }
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool
    {
        if(textView == PoastTitle) {
            if PoastTitle.text.characters.count > 44 &&  text.characters.count != 0 {
                return false
            }
            else {
                let  char = text.cStringUsingEncoding(NSUTF8StringEncoding)!
                let isBackSpace = strcmp(char, "\\b")
                
                if (isBackSpace == -92 ) {
                    print("Backspace was pressed")
                    if(titleCharacterCount < 45 )
                    {
                        titleCharacterCount = titleCharacterCount + 1
                        titleCountLbl.text = String(titleCharacterCount)
                    }
                    
                }
                else {
                    titleCharacterCount = 44 - PoastTitle.text!.characters.count
                    titleCountLbl.text = String(titleCharacterCount)
                    
                }
                
                if titleCharacterCount <= 10 {
                    titleCountLbl.textColor = UIColor.redColor()
                } else {
                    titleCountLbl.textColor = UIColor.blackColor()
                }
                return true
            }
        }
            
        else  if(textView == PoastDescription) {
            if PoastDescription.text.characters.count > 89 &&  text.characters.count != 0 {
                return false
            }
            else {
                let  char = text.cStringUsingEncoding(NSUTF8StringEncoding)!
                let isBackSpace = strcmp(char, "\\b")
                
                if (isBackSpace == -92 ) {
                    if(descCharacterCount < 90 ) {
                        descCharacterCount = descCharacterCount + 1
                        descCountLbl.text = String(descCharacterCount)
                    }
                }
                else {
                    descCharacterCount = 89 - PoastDescription.text!.characters.count
                    descCountLbl.text = String(descCharacterCount)
                }
                if descCharacterCount <= 10 {
                    descCountLbl.textColor = UIColor.redColor()
                } else {
                    descCountLbl.textColor = UIColor.blackColor()
                }
                return true
            }
        }
        return true
    }
    
}
