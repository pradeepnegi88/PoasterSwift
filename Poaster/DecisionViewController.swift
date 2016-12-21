//
//  DecisionViewController.swift
//  Poaster
//
//  Created by Vinod Sobale on 13/12/16.
//  Copyright © 2016 Poaster LLC. All rights reserved.
//

import UIKit


class DecisionViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    
    @IBOutlet weak var DecisionPicker: UIPickerView!

    let DecisionPickerData = ["Yes, I want to make sales", "No, just marketing for now"]
    
    var MarketingDecision: String = ""
    var BusinessTitle: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        DecisionPicker.delegate = self
        DecisionPicker.dataSource = self
        
        print(MarketingDecision, BusinessTitle)
        MarketingDecision = DecisionPickerData[0]
        
        self.navigationController!.navigationBar.tintColor = UIColor(red: 152/256, green: 201/256, blue: 64/256, alpha: 1.0)
        
        // Changing the case of the Back link
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "BACK", style: .Plain, target: nil, action: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let logButton: UIBarButtonItem = UIBarButtonItem(title: "NEXT", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(DecisionViewController.NextDecision))
        self.navigationItem.rightBarButtonItem = logButton
    }
    
    func NextDecision() {
        print("Nice")
        
        
        // IF YOU WANT 1PAY
        if MarketingDecision == "Yes, I want to make sales" {
            // let StripeSetupVC = self.storyboard?.instantiateViewControllerWithIdentifier("StripeSetupSBView") as! StripeSetupViewController
            // StripeSetupVC.FinalBusinessName = BusinessTitle
            // self.presentViewController(StripeSetupVC, animated: true, completion: nil)
            
            performSegueWithIdentifier("StripeSetupView", sender: self)
            
        } else {
            
            // IF YOU JUST WANT TO DO MARKETING
            
            let SecondVC = self.storyboard?.instantiateViewControllerWithIdentifier("CameraStoryBoardID") as! SecondViewController
            self.navigationController!.pushViewController(SecondVC, animated: true)
        }
        
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return DecisionPickerData.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return DecisionPickerData[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print(DecisionPickerData[row])
        MarketingDecision = DecisionPickerData[row]
    }
    
    func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let titleData = DecisionPickerData[row]
        let myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName:UIFont(name: "Helvetica Neue", size: 15.0)!,NSForegroundColorAttributeName:UIColor.blackColor()])
        return myTitle
    }
    
    func finalPush() {
        let SecondVC = self.storyboard?.instantiateViewControllerWithIdentifier("CameraStoryBoardID") as! SecondViewController
        self.navigationController!.pushViewController(SecondVC, animated: true)
    }
    
    func MoveTotheFinalAction() {
        
        let SecondVC = self.storyboard?.instantiateViewControllerWithIdentifier("CameraStoryBoardID") as! SecondViewController
        self.navigationController!.pushViewController(SecondVC, animated: true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        // SENDING BUSINESS NAME VIA SEGUE
        let StripeSetupVC = segue.destinationViewController as! StripeSetupViewController
        StripeSetupVC.FinalBusinessName = BusinessTitle
        
    }

}
