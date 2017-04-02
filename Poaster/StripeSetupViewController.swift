//
//  StripeSetupViewController.swift
//  poaster
//
//  Created by Vinod Sobale on 4/5/16.
//  Copyright Â© 2016 Vinod Sobale. All rights reserved.
//

import UIKit
import WebKit
import Alamofire
import SwiftyJSON

class StripeSetupViewController: UIViewController, UIWebViewDelegate {
    
    let prefs = NSUserDefaults.standardUserDefaults()
    
    // @IBOutlet weak var SearchBar: UISearchBar!
    @IBOutlet weak var WebView: UIWebView!
    @IBOutlet weak var ActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var URLBar: UITextField!
    
    var StripeSetupURL: String! = nil
    var FinalBusinessName: String! = nil
    var StripeDecisionVC: StripeDecisionViewController!
    var SegueBusinessName: String! = nil
    
    func getStripeSetupParams() {
        
        if let authtoken = prefs.stringForKey("authtoken"){
            
            let hosturl = "\(HOST)/api/v1/user/stripe_provider_info.json?auth_token=\(authtoken)"
            
            Alamofire.request(.GET, hosturl, encoding: .JSON)
                .responseJSON {
                    response in debugPrint(response)
                    // prints detailed description of all response properties
                    // print(response.result.value)
                    if let value = response.result.value {
                        let json = JSON(value)
                        if json["success"] == true {
                            print("SuccessFul")
                            print(json["data"])
                            
                            let client_id = json["data"]["client_id"]
                            let scope = json["data"]["scope"]
                            let response_type = json["data"]["response_type"]
                            let state = json["data"]["state"]
                            
                            self.StripeSetupURL = "https://connect.stripe.com/oauth/authorize?client_id=\(client_id)&response_type=\(response_type)&scope=\(scope)&state=\(state)"
                            // print(self.StripeSetupURL)
                            self.LoadWebPage()
                        } else {
                            print("UnsuccessFul")
                        }
                    } // saving response in // let value
            }// Alamofire request
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // hiding navigation bar
        self.navigationController?.navigationBarHidden = true
        
        getStripeSetupParams()
        
        WebView.delegate = self;
        WebView.scalesPageToFit = true
        
        ActivityIndicator.hidden = true
        
        WebView.keyboardDisplayRequiresUserAction = true
        
        WebView.frame = self.view.frame;
        
        URLBar.backgroundColor = UIColor.whiteColor()
        
        URLBar.layer.borderColor = UIColor.lightGrayColor().CGColor
        URLBar.layer.borderWidth = 1.0
        
        print("Segue Business name has been recieved \(SegueBusinessName)")

    }
    
    @IBAction func DismissStripeSetup(sender: UIButton) {
        dismissViewControllerAnimated(true) { 
            // 
            
            let MakePoastVC = self.storyboard?.instantiateViewControllerWithIdentifier("MakePoastView") as! MakePoastViewController
            MakePoastVC.OnePaySwitch.on = false
            
        }
    }
    
    
    func LoadWebPage() {
        let url = NSURL(string: StripeSetupURL!)
        let req = NSURLRequest(URL:url!)
        self.WebView!.loadRequest(req)
    }
    
    func matchesForRegexInText(regex: String!, text: String!) -> [String] {
        
        do {
            let regex = try NSRegularExpression(pattern: regex, options: [])
            let nsString = text as NSString
            let results = regex.matchesInString(text,
                                                options: [], range: NSMakeRange(0, nsString.length))
            return results.map { nsString.substringWithRange($0.range)}
        } catch _ as NSError {
            // print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
    
    func SetBuyNowBusinessDetail() {
        if let AToken = prefs.stringForKey("authtoken"){
            let hosturl = "\(HOST)/api/v1/user/set_business_detail.json"
            
            if SegueBusinessName == nil {
                print("SegueBusinessName empty")
                Alamofire.request(.POST, hosturl,
                    parameters: ["auth_token": AToken, "business_details": ["alternate_action": "buy_now", "business_name": FinalBusinessName]], encoding: .JSON)
                    .responseJSON {
                        response in debugPrint(response)
                        // prints detailed description of all response properties
                        if let value = response.result.value {
                            let json = JSON(value)
                            print(json)
                            if json["success"] == true {
                                
                                if json["request_status"] == "success" {
                                    print("API call successful!")
                                    print("Business detail set for Buy Now!")
                                    print(json)
                                    
                                    let reg_complete_Flag = Bool(json["data"]["registration_completed"])
                                    self.prefs.setValue(reg_complete_Flag, forKey: "registration_completed")
                                    
                                } else {
                                    let alert = UIAlertController(title: "Oops!", message: String(json["data"]["error"]), preferredStyle: .Alert)
                                    let firstAction = UIAlertAction(title: "Dismiss", style: .Default) { (alert: UIAlertAction!) -> Void in
                                        self.navigationController!.popViewControllerAnimated(true)
                                    }
                                    alert.addAction(firstAction)
                                    self.presentViewController(alert, animated: true, completion:nil)
                                }
                            } else {
                                print("API call failed!")
                            }
                        } // saving response in // let value
                }// Alamofire request
            }
        }
    }
    
    func MoveToCamera() {
        let currentURL : NSString = (WebView.request?.URL!.absoluteString)!
        
        print("\(currentURL) this is current URL")
        
        // https://poasterapp.com/users/auth/stripe_connect/callback
        
        let matches = matchesForRegexInText("users/auth/stripe_connect/callback?", text: currentURL as String)
        // print("This is \(matches)")
        
        if matches != [] {
            // print("This is the page")
            
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
                                let StripeAccountID = json["data"]["stripe_account_id"]
                                if StripeAccountID != "" {
                                    print("Stripe Account set up!")
                                    self.SetBuyNowBusinessDetail()
                                    self.dismissViewControllerAnimated(true, completion: nil)
                                    modelDismissDelegte?.finalPush()
                                    self.prefs.setBool(true, forKey: "OnePaySetup")
                                }
                            } else {
                                let alert = UIAlertController(title: "Oops!", message: String(json["error"]), preferredStyle: .Alert) // 1
                                
                                let firstAction = UIAlertAction(title: "Dismiss", style: .Default) { (alert: UIAlertAction!) -> Void in
                                    
                                } // 2
                                
                                alert.addAction(firstAction)
                                self.presentViewController(alert, animated: true, completion:nil)
                                print("UnsuccessFul")
                            }
                        } // saving response in // let value
                }// Alamofire request
            }
        } else {
            //  ("This is not the page. Do not do anything yet")
        }
    } // MoveToCamera
    
    // Delegate Methods
    func webViewDidStartLoad(webView : UIWebView) {
        ActivityIndicator.hidden = false
        ActivityIndicator.startAnimating()
    }
    
    func webViewDidFinishLoad(webView : UIWebView) {
        ActivityIndicator.hidden = true
        ActivityIndicator.stopAnimating()
        
        MoveToCamera()
    }
    
}
