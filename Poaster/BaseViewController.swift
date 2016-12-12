//
//  BaseViewController.swift
//  poaster
//
//  Created by Amol Patil on 27/02/16.
//  Copyright © 2016 Vinod Sobale. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
    
    var profileButton:UIButton!;
    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        profileButton = UIButton(type: UIButtonType.System)
//        profileButton.frame = CGRectMake(20, 500, 44, 44)
//        profileButton.backgroundColor = UIColor.greenColor()
//        profileButton.setTitle("Profile", forState: UIControlState.Normal)
//        
//        profileButton.addTarget(self, action: "profileBtnClicked:", forControlEvents: UIControlEvents.TouchUpInside)
//        self.view.addSubview(profileButton)
//        
//    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    func profileBtnClicked(sender:UIButton!) {
//        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//        let vc: MyProfileViewController = storyboard.instantiateViewControllerWithIdentifier("profileStoryBoardId") as! MyProfileViewController
//        self.presentViewController(vc, animated: true, completion: nil)
//    }
    
}
