//
//  WelcomeViewController.swift
//  poaster
//
//  Created by Vinod Sobale on 12/29/15.
//  Copyright © 2015 Vinod Sobale. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class WelcomeViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var picker: UIPickerView!
    
    let prefs = NSUserDefaults.standardUserDefaults()
    
    var business_id: Int! = nil
    var business_name: String! = ""
    
    var pickerData = ["Beauty", "Fashion", "Fitness", "Food Service", "Arts/Crafts", "Other-service", "Other-goods"]
    
    // Businesses Dictionary

    var businesses: [String: Int] = ["Beauty": 1, "Fashion": 2, "Fitness": 3, "Food Service": 4, "Arts/Crafts": 5, "Other-service": 6, "Other-goods": 7]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.picker.delegate = self
        self.picker.dataSource = self
        
        self.navigationController!.navigationBar.tintColor = UIColor(red: 152/256, green: 201/256, blue: 64/256, alpha: 1.0)
        
        let logoImage:UIImage = UIImage(named: "camera-logo.png")!
        self.navigationItem.titleView = UIImageView(image: logoImage)
        
        business_name = pickerData[0]
        
        // Changing the case of the Back link
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "BACK", style: .Plain, target: nil, action: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let logButton : UIBarButtonItem = UIBarButtonItem(title: "NEXT", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(WelcomeViewController.setBusiness))
        self.navigationItem.rightBarButtonItem = logButton
    }
    
    func customFontUtils() {
        if let font = UIFont(name: "ProximaNova-Regular", size: 18) {
            UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName: font]
        }
    }
    
    func setBusiness() {
        
        for (key, value) in businesses {
            if key == business_name {
                business_id = value
                break
            }
        }
        
        let prefs = NSUserDefaults.standardUserDefaults()
        if let AToken = prefs.stringForKey("authtoken"){

            let hosturl = "\(HOST)/api/v1/user/set_business.json"
            
            Alamofire.request(.POST, hosturl,
                parameters: ["auth_token": AToken, "business": ["business_id": business_id]], encoding: .JSON)
                .responseJSON {
                    response in debugPrint(response)     // prints detailed description of all response properties
                    if let value = response.result.value {
                        let json = JSON(value)
                        print(json)
                        if json["success"] == true {
                            
                            let reg_complete_Flag = Bool(json["data"]["registration_completed"])
                            let reg_complete = Bool(reg_complete_Flag);
                            prefs.setValue(reg_complete, forKey: "registration_completed")
                            
                            if let StepNumber = json["data"]["step"].int {
                                // SAVING A STEP NUMBER
                                self.prefs.setValue(StepNumber, forKey: "step_number")
                                print("my step number is this from welcomeview \(StepNumber)")
                            }

                            print("API Call Successful!")
                        } else {
                            print("API Call Failed!")
                        }
                    } // saving response in // let value
            }// Alamofire request
        }
        
        let BusinessNameVC = self.storyboard?.instantiateViewControllerWithIdentifier("BusinessNameView") as! BusinessNameViewController
        
        BusinessNameVC.ReceivedBizType = business_name
        
        self.navigationController!.pushViewController(BusinessNameVC, animated: true)
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        business_name = pickerData[row]
    }
}
