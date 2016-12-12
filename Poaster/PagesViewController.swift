//
//  PagesViewController.swift
//  poaster
//
//  Created by Vinod Sobale on 6/1/16.
//  Copyright © 2016 Vinod Sobale. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import FBSDKCoreKit
import FBSDKLoginKit
import BXProgressHUD

class PagesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let prefs = NSUserDefaults.standardUserDefaults()
    
    @IBOutlet weak var tableView: UITableView!
    
    var arr: [FacebookPageModel] = []
    var PageNames: [String] = []
    var PoastID: Int! = nil
    var PageAccessToken: String! = nil
    let progressHud = BXProgressHUD()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GetFBPages()
        view.addSubview(progressHud)
        progressHud.show()
    }
    
    @IBAction func DismissPagesView(sender: AnyObject) {
        socialViewSelectionDelegate?.MakeFaceBookInactive()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    
    func GetFBPages() {
        if let authtoken = prefs.stringForKey("authtoken"){

            let hosturl = "\(HOST)/api/v1/user/get_fb_accounts.json"
            
            Alamofire.request(.POST, hosturl,
                parameters: ["auth_token": authtoken, "id": PoastID, "providers": ["facebook"]], encoding: .JSON)
                .responseJSON {
                    response in debugPrint(response)
                    // prints detailed description of all response properties
                    print(response.result.value)
                    if let value = response.result.value {
                        let json = JSON(value)
                        if json["success"] == true {
                            let data = json["data"]
                            
                            for i in 0 ..< data.count {
                                let pagename = String(data[i]["name"])
                                let pagetoken = String(data[i]["access_token"])
                                
                                let FBPage = FacebookPageModel()
                                
                                FBPage.page_name = pagename
                                FBPage.page_token = pagetoken
                                
                                self.arr.append(FBPage)
                            }
                            
                            self.tableView.reloadData()
                            self.progressHud.hide()
                            print("Got FB pages!")
                            
                        } else {
                            self.progressHud.hide()
                            print("Couldn't get FB pages!")
                        }
                    } // saving response in // let value
            }// Alamofire request
        }
    } // GetFBPages
    
    func StoreFBPageToken(FBPageToken: String) {
        print(FBSDKAccessToken.currentAccessToken().tokenString)
        if (FBSDKAccessToken.currentAccessToken() != nil) {
            let uid = FBSDKAccessToken.currentAccessToken().userID
            let ExpirationDate = FBSDKAccessToken.currentAccessToken().expirationDate
            let ExDate = String(ExpirationDate)
            print("Got the token")
            
            if uid != nil && ExpirationDate != nil {
                if let authtoken = prefs.stringForKey("authtoken"){
                    
                    let hosturl = "\(HOST)/api/v1/user/store.json"
                    
                    Alamofire.request(.POST, hosturl,
                        parameters: ["auth_token": authtoken,
                            "providers": ["name": "facebook", "oauth_token": FBPageToken, "oauth_expires_at": ExDate, "uid": uid]
                        ], encoding: .JSON)
                        .responseJSON {
                            response in debugPrint(response)
                            // prints detailed description of all response properties
                            print(response.result.value)
                            if let value = response.result.value {
                                let json = JSON(value)
                                if json["success"] == true {
                                    print("SuccessFul")
                                    self.dismissViewControllerAnimated(true, completion: nil)
                                } else {
                                    print("UnsuccessFul")
                                }
                            } // saving response in // let value
                    }// Alamofire request
                }
            }
        }
    } // StoreFBPageToken
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arr.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CELL") as UITableViewCell!
        
        cell.textLabel?.text = arr[indexPath.row].page_name
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        PageAccessToken = arr[indexPath.row].page_token
        StoreFBPageToken(PageAccessToken)
    }
    
}
