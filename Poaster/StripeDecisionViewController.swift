//
//  StripeDecisionViewController.swift
//  poaster
//
//  Created by Vinod Sobale on 4/5/16.
//  Copyright © 2016 Vinod Sobale. All rights reserved.
//

import UIKit
import Mixpanel

protocol ModelDismissDelegte {
    func finalPush()
}

//this is the variable that we use to call the methods.
var modelDismissDelegte:ModelDismissDelegte?


class StripeDecisionViewController: UIViewController, ModelDismissDelegte {
    
    @IBOutlet weak var Switch: UISwitch!
    @IBOutlet weak var NoticeView: UITextView!
    @IBOutlet weak var QuestionView: UITextView!

    var bizName: String! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.

        QuestionView.font = UIFont(name: "ProximaNova-Regular", size: 16)
        NoticeView.font = UIFont(name: "ProximaNova-Regular", size: 14)
        Switch.on = false
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        
        modelDismissDelegte = self
    }
    
    func finalPush() {
        let SecondVC = self.storyboard?.instantiateViewControllerWithIdentifier("CameraStoryBoardID") as! SecondViewController
        self.navigationController!.pushViewController(SecondVC, animated: true)
    }
    
    @IBAction func BringStripeSetup(sender: UISwitch) {
        if Switch.on {
            Mixpanel.mainInstance().track(event: "Switch - Stripe setup selected")
            let StripeSetupVC = self.storyboard?.instantiateViewControllerWithIdentifier("StripeSetupSBView") as! StripeSetupViewController
            
            StripeSetupVC.StripeDecisionVC = self
            StripeSetupVC.FinalBusinessName = bizName
            self.presentViewController(StripeSetupVC, animated: true, completion: nil)

        }
    }

    func MoveTotheFinalAction() {
        
        let SecondVC = self.storyboard?.instantiateViewControllerWithIdentifier("CameraStoryBoardID") as! SecondViewController
        self.navigationController!.pushViewController(SecondVC, animated: true)
    }
    
}