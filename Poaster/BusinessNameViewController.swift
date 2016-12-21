//
//  BusinessNameViewController.swift
//  poaster
//
//  Created by Vinod Sobale on 2/21/16.
//  Copyright © 2016 Vinod Sobale. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class BusinessNameViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var DBANameField: UITextField!
    @IBOutlet weak var countLabel: UILabel!
    
    var ReceivedBizType: String! = ""
    var characterCount: Int! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DBANameField.addTarget(self, action: #selector(BusinessNameViewController.textFieldDidChange), forControlEvents: UIControlEvents.EditingChanged)
        
        let logoImage:UIImage = UIImage(named: "camera-logo.png")!
        self.navigationItem.titleView = UIImageView(image: logoImage)
        

        self.navigationController!.navigationBar.tintColor = UIColor(red: 152/256, green: 201/256, blue: 64/256, alpha: 1.0)
        
        // Changing the case of the Back link
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "BACK", style: .Plain, target: nil, action: nil)
        
        self.DBANameField.delegate = self;
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let logButton : UIBarButtonItem = UIBarButtonItem(title: "NEXT", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(BusinessNameViewController.setBusinessName))
        
        logButton.action = nil

        self.navigationItem.rightBarButtonItem = nil
    }
    
    func textFieldDidChange() {
        
        characterCount = 31 - DBANameField.text!.characters.count
        let characterCountString = String(31 - DBANameField.text!.characters.count)
    
        if DBANameField.text != "" {
            let logButton : UIBarButtonItem = UIBarButtonItem(title: "NEXT", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(BusinessNameViewController.setBusinessName))
            
            self.navigationItem.rightBarButtonItem = logButton
        } else {
            self.navigationItem.rightBarButtonItem = nil
        }
        
        countLabel.text = characterCountString
        
        if characterCount <= 10 {
            countLabel.textColor = UIColor.redColor()
        } else {
            countLabel.textColor = UIColor.blackColor()
        }
    }
    
    func textField(textFieldToChange: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        // limit to 4 characters
        let characterCountLimit = 31
        
        // We need to figure out how many characters would be in the string after the change happens
        let startingLength = textFieldToChange.text?.characters.count ?? 0
        let lengthToAdd = string.characters.count
        let lengthToReplace = range.length
        
        let newLength = startingLength + lengthToAdd - lengthToReplace
        
        return newLength <= characterCountLimit
    }
    
    
    func setBusinessName() {
        // set business name API call
        
        let BusinessName = DBANameField.text
        
        let CallToActionVC = self.storyboard?.instantiateViewControllerWithIdentifier("CallToActionView") as! CallToActionViewController
        CallToActionVC.receivedBizName = BusinessName
        
        CallToActionVC.receivedBizType = self.ReceivedBizType
        self.navigationController!.pushViewController(CallToActionVC, animated: true)
    }
    
}
