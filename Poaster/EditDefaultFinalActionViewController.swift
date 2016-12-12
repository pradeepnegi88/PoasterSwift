//
//  EditDefaultFinalActionViewController.swift
//  poaster
//
//  Created by Poaster on 15/03/16.
//  Copyright © 2016 Poaster. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import BXProgressHUD

class EditDefaultFinalActionViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource  {
    
    let prefs = NSUserDefaults.standardUserDefaults()
    var progressHud = BXProgressHUD()
    
    @IBOutlet weak var myLabel: UILabel!
    
    @IBOutlet weak var callNowView: UIView!
    
    @IBOutlet weak var callNowNumber: UITextField!
    
    @IBOutlet weak var otherView: UIView!
    @IBOutlet weak var CheckOutView: UIView!
    
    @IBOutlet weak var otherCallNowNumber: UITextField!
    @IBOutlet weak var url: UITextField!
    @IBOutlet weak var CheckOutViewURL: UITextField!
    
    
    @IBOutlet weak var optionPickerView: UIPickerView!
    
    var pickerViewData = ["Business Phone number", "Online Booking / Website"]
    
    var selectedCallToAction: String = ""
    
    var bizName: String! = nil
    
    var DefaultAction: String! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(progressHud)
        
        getProfileInfo()
        
        myLabel.text = selectedCallToAction
        
        self.optionPickerView.delegate = self
        self.optionPickerView.dataSource = self
        
        self.navigationController!.navigationBar.tintColor = UIColor(red: 152/256, green: 201/256, blue: 64/256, alpha: 1.0)
        
        print(selectedCallToAction)
        callNowView.hidden = true
        otherView.hidden = true
        
        url.hidden = true;
        // enterWebsiteLbl.hidden = true;
        
        customTextFieldFont()
        customCallNowNumberField()
        customOtherCallNowNumberField()
        customURLField()
        
        if selectedCallToAction == "Call Now" {
            callNowView.hidden = false
            otherView.hidden = true
            CheckOutView.hidden = true
        } else if selectedCallToAction == "Check It Out" {
            callNowView.hidden = true
            otherView.hidden = true
            CheckOutView.hidden = false
        } else {
            callNowView.hidden = true
            otherView.hidden = false
            CheckOutView.hidden = true
        }
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let logButton : UIBarButtonItem = UIBarButtonItem(title: "FINISH", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(EditDefaultFinalActionViewController.setBusinessDetail))
        self.navigationItem.rightBarButtonItem = logButton
    }
    
    func CreateURL(url: String, CTAAction: String, ExtraParams: String = "") {
        if (url.rangeOfString("http://") != nil) || (url.rangeOfString("https://") != nil) {
            validateURL(url, cta_action: CTAAction, other_call_number: ExtraParams)
        } else {
            let NewURL = "http://"+url
            print("appended scheme")
            validateURL(NewURL, cta_action: CTAAction, other_call_number: ExtraParams)
        }
    }
    
    
    func validateURL(url: String, cta_action: String, other_call_number: String? = nil) {
        if let AToken = self.prefs.stringForKey("authtoken"){
            let APIURL = "\(HOST)/api/v1/user/update_business_detail.json"
            
            self.progressHud.show()
            Alamofire.request(.GET, url).response { request, response, data, error in
                
                if response != nil {
                    print("received positive response ")
                    
                    if cta_action == "check_it_out" {
                        Alamofire.request(.PUT, APIURL,
                            parameters: ["auth_token": AToken, "business_details": ["action": "check_it_out", "webpage_url": url]], encoding: .JSON)
                            .responseJSON {
                                response in debugPrint(response)     // prints detailed description of all response properties
                                if let value = response.result.value {
                                    let json = JSON(value)
                                    print(json)
                                    if json["success"] == true {
                                        
                                        let SecondVC = self.storyboard!.instantiateViewControllerWithIdentifier("CameraStoryBoardID")
                                        self.navigationController!.pushViewController(SecondVC, animated: true);
                                        
                                        print("API call successful!")
                                        print(json)
                                    } else {
                                        print("API call failed!")
                                    }
                                } // saving response in // let value
                        }// Alamofire request
                    } else {
                        if let othercallnumber = other_call_number {
                            self.BookNowAPICall(APIURL, AToken: AToken, OtherCallNumber: othercallnumber, WebPageURL: url)
                        }
                    }
                }
                
                if error != nil {
                    self.progressHud.hide()
                    self.displayAlertMessage("URL provided doesn't exist")
                }
            }
        }// Checking if Auth Token exists
    }
    
    
    func isNumberLongEnough(Number: String) -> Bool {
        if Number == "" || Number.characters.count != 10  {
            return false
        }
        return true;
    }
    
    // BOOK NOW API CALL
    
    func BookNowAPICall(HostURL: String, AToken: String, OtherCallNumber: String, WebPageURL: String) {
        
        Alamofire.request(.PUT, HostURL,
            parameters: ["auth_token": AToken, "business_details": ["action": "reservation", "phone_number": OtherCallNumber, "webpage_url": WebPageURL]], encoding: .JSON)
            .responseJSON {
                response in debugPrint(response)     // prints detailed description of all response properties
                if let value = response.result.value {
                    let json = JSON(value)
                    print(json)
                    if json["success"] == true {
                        
                        let SecondVC = self.storyboard!.instantiateViewControllerWithIdentifier("CameraStoryBoardID")
                        self.navigationController!.pushViewController(SecondVC, animated: true);
                        
                        print("API call successful!")
                        print(json)
                    } else {
                        print("API call failed!")
                    }
                } // saving response in // let value
        }// Alamofire request
    }
    
    func getProfileInfo() {
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
                            
                            self.DefaultAction = String(json["data"]["action"])
                            self.bizName = json["data"]["business"]["business_name"].string
                            
                            print("API Call Successful!")
                            
                        } else {
                            print("API Call Failed!")
                        }
                    } // saving response in // let value
            }// Alamofire request
        }
    }
    
    
    func customTextFieldFont() {
        let font = UIFont(name: "ProximaNova-Regular", size: 16)!
        let attributes = [
            NSForegroundColorAttributeName: UIColor.lightGrayColor(),
            NSFontAttributeName : font]
        
        callNowNumber.attributedPlaceholder = NSAttributedString(string: "Enter your phone number",
                                                                 attributes:attributes)
        
        otherCallNowNumber.attributedPlaceholder = NSAttributedString(string: "Enter your phone number",
                                                                      attributes:attributes)
        
        url.attributedPlaceholder = NSAttributedString(string: "Enter URL",
                                                       attributes:attributes)
    }
    
    func setBusinessDetail() {
        let hosturl = "\(HOST)/api/v1/user/update_business_detail.json"
        if selectedCallToAction == "Call Now" {
            let phoneNumber = callNowNumber.text!
            if isNumberLongEnough(phoneNumber) {
                if let AToken = prefs.stringForKey("authtoken"){
                    showActivityIndicator(self.view)
                    Alamofire.request(.PUT, hosturl,
                        parameters: ["auth_token": AToken,
                            "business_details": [
                                "action": "call_now",
                                "phone_number": phoneNumber
                            ]
                        ], encoding: .JSON)
                        .responseJSON {
                            response in debugPrint(response)     // prints detailed description of all response properties
                            if let value = response.result.value {
                                let json = JSON(value)
                                print(json)
                                if json["success"] == true {
                                    let SecondVC = self.storyboard!.instantiateViewControllerWithIdentifier("CameraStoryBoardID")
                                    self.navigationController!.pushViewController(SecondVC, animated: true)
                                    print(json)
                                    print("API call successful!")
                                } else {
                                    print("API call failed!")
                                }
                            } // saving response in // let value
                    }// Alamofire request
                }
            }
            else {
                displayAlertMessage("Phone number must have 10 digits");
            }
        } else if selectedCallToAction == "Check It Out" {
            if let checkItOutURL = CheckOutViewURL.text {
                print("Running CreateURL function now")
                CreateURL(checkItOutURL, CTAAction: "check_it_out")
            }// RMEOVE OPTIONAL FROM THE VALUE
        } else {
            var urlvalue = url.text!
            let othercallnumbervalue = otherCallNowNumber.text!
            if let AToken = prefs.stringForKey("authtoken") {
                if optionPickerView.selectedRowInComponent(0) == 0 {
                    if isNumberLongEnough(othercallnumbervalue) {
                        showActivityIndicator(self.view)
                        urlvalue = ""
                        BookNowAPICall(hosturl, AToken: AToken, OtherCallNumber: othercallnumbervalue, WebPageURL: urlvalue)
                    } else {
                        displayAlertMessage("Phone number must have 10 digits");
                    }
                } else {
                    CreateURL(urlvalue, CTAAction: "reservation", ExtraParams: othercallnumbervalue)
                }
            }
            else {
                displayAlertMessage("Please enter valid details");
            }
        }
    }// setBusinessDetail()
    
    
    func customCallNowNumberField() {
        let border = CALayer()
        let width = CGFloat(1.0)
        border.borderColor = UIColor.lightGrayColor().CGColor
        border.borderWidth = width
        
        border.frame = CGRect(x: 0, y: callNowNumber.frame.size.height - width, width:  callNowNumber.frame.size.width, height: callNowNumber.frame.size.height)
        callNowNumber.layer.addSublayer(border)
        callNowNumber.layer.masksToBounds = true
    }
    
    
    func customOtherCallNowNumberField() {
        let border = CALayer()
        let width = CGFloat(1.0)
        border.borderColor = UIColor.lightGrayColor().CGColor
        border.borderWidth = width
        
        border.frame = CGRect(x: 0, y: otherCallNowNumber.frame.size.height - width, width:  otherCallNowNumber.frame.size.width, height: otherCallNowNumber.frame.size.height)
        otherCallNowNumber.layer.addSublayer(border)
        otherCallNowNumber.layer.masksToBounds = true
    }
    
    func customURLField() {
        let border = CALayer()
        let width = CGFloat(1.0)
        border.borderColor = UIColor.lightGrayColor().CGColor
        border.borderWidth = width
        
        border.frame = CGRect(x: 0, y: url.frame.size.height - width, width:  url.frame.size.width, height: url.frame.size.height)
        url.layer.addSublayer(border)
        url.layer.masksToBounds = true
    }
    
    func UIColorFromHex(rgbValue:UInt32, alpha:Double=1.0)->UIColor {
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        return UIColor(red:red, green:green, blue:blue, alpha:CGFloat(alpha))
    } //UIColorFromHex
    
    func showActivityIndicator(uiView: UIView) {
        let container: UIView = UIView()
        container.frame = uiView.frame
        container.center = uiView.center
        container.backgroundColor = UIColorFromHex(0xffffff, alpha: 0.3)
        
        let loadingView: UIView = UIView()
        loadingView.frame = CGRectMake(0, 0, 80, 80)
        loadingView.center = uiView.center
        loadingView.backgroundColor = UIColorFromHex(0x444444, alpha: 0.7)
        loadingView.clipsToBounds = true
        loadingView.layer.cornerRadius = 10
        
        let actInd: UIActivityIndicatorView = UIActivityIndicatorView()
        actInd.frame = CGRectMake(0.0, 0.0, 40.0, 40.0);
        actInd.activityIndicatorViewStyle =
            UIActivityIndicatorViewStyle.WhiteLarge
        actInd.center = CGPointMake(loadingView.frame.size.width / 2,
                                    loadingView.frame.size.height / 2);
        loadingView.addSubview(actInd)
        container.addSubview(loadingView)
        uiView.addSubview(container)
        actInd.startAnimating()
    } // showActivityIndicator
    
    
    //  # pragma mark UIPikserView methods
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerViewData.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerViewData[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print(pickerViewData[row])
        
        if row == 0 {
            //Office Mobile Number is selected
            url.hidden = true;
            otherCallNowNumber.hidden = false;
        }
        else if row == 1 {
            //Online Website is selected
            otherCallNowNumber.hidden = true;
            url.hidden = false;
        }
    }
    
    func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let titleData = pickerViewData[row]
        let myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName:UIFont(name: "Helvetica Neue", size: 15.0)!,NSForegroundColorAttributeName:UIColor.blackColor()])
        return myTitle
    }
    
    func displayAlertMessage(message: String) {
        let alertView = UIAlertController(title: "Error", message: message, preferredStyle: .Alert);
        alertView.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil));
        presentViewController(alertView, animated: true, completion: nil)
    }
    
}
