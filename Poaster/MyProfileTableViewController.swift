//
//  MyProfileTableViewController.swift
//  Pods
//
//  Created by Vinod Sobale on 3/18/16.
//
//

import UIKit
import Alamofire
import SwiftyJSON

class MyProfileTableViewController: UITableViewController {
    
    @IBOutlet weak var UserName: UILabel!
    @IBOutlet weak var DBAName: UILabel!
    @IBOutlet weak var ViewsCount: UILabel!
    @IBOutlet weak var ClicksCount: UILabel!
    @IBOutlet weak var SharesCount: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        getProfileInfo()
        // UIApplication.sharedApplication().applicationIconBadgeNumber = 0
    }
    
    @IBAction func DismissProfileView(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func getProfileInfo() {
        let prefs = NSUserDefaults.standardUserDefaults()
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
                            
                            let views = json["data"]["total_poasts_views"].string
                            let clicks = json["data"]["total_poasts_clicks"].string
                            let shares = json["data"]["user_poasts_count"].string
                            
                            let UserNameString = json["data"]["user_name"].string
                            let DBAString = json["data"]["business"]["business_name"].string

                            // Capitalizing Username and DBAName
                            self.UserName.text = UserNameString!.capitalizedString
                            self.DBAName.text = DBAString!.capitalizedString

                            self.ViewsCount.text = views
                            self.ClicksCount.text = clicks
                            self.SharesCount.text = shares
                            print("API Call Successful!")

                        } else {
                            print("API Call Failed!")
                        }
                    } // saving response in // let value
            }// Alamofire request
        }
    }
    
}
