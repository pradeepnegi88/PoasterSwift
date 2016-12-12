//
//  EditDefaultActionViewController.swift
//  poaster
//
//  Created by Amol Patil on 15/03/16.
//  Copyright © 2016 Vinod Sobale. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class EditDefaultActionViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    let prefs = NSUserDefaults.standardUserDefaults()
    
    @IBOutlet weak var CTAPicker: UIPickerView!
    
    var CTAData = ["Call Now", "Book Now", "Check It Out"]
    
    var currentSelection: String = ""
    
    var DefaultAction: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentSelection = CTAData[0]

        getProfileInfo()
        
        self.CTAPicker.delegate = self
        self.CTAPicker.dataSource = self
        
        self.navigationController!.navigationBar.tintColor = UIColor(red: 152/256, green: 201/256, blue: 64/256, alpha: 1.0)
        
        // Changing the case of the Back link
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "BACK", style: .Plain, target: nil, action: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let logButton : UIBarButtonItem = UIBarButtonItem(title: "NEXT", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(EditDefaultActionViewController.chooseCallToAction))
        self.navigationItem.rightBarButtonItem = logButton
        
        let CancelButton : UIBarButtonItem = UIBarButtonItem(title: "CANCEL", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(EditDefaultActionViewController.CancelChooseCallToAction))
        self.navigationItem.leftBarButtonItem = CancelButton
    }
    
    func CancelChooseCallToAction() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func chooseCallToAction() {
        let FinalActionVC = self.storyboard?.instantiateViewControllerWithIdentifier("EditDefaultFinalActId") as! EditDefaultFinalActionViewController
        self.navigationController!.pushViewController(FinalActionVC, animated: true)
        FinalActionVC.selectedCallToAction = currentSelection
    }
    
    func getProfileInfo() {
        if let AToken = prefs.stringForKey("authtoken"){
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
                            
                            self.DefaultAction = String(json["data"]["business"]["action"])
                            
                        } else {
                            print("API Call Failed!")
                        }
                    } // saving response in // let value
            }// Alamofire request
        }
    } // getProfileInfo
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return CTAData.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return CTAData[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print(CTAData[row])
        currentSelection = CTAData[row]
    }
    
}
