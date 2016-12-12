//
//  MyProfileViewController.swift
//  Poaster
//
//  Created by Vinod Sobale on 19/11/16.
//  Copyright © 2016 Poaster LLC. All rights reserved.
//

import UIKit

class MyProfileViewController: UIViewController {
    
    @IBOutlet weak var NavigationBarView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NavigationBarView.layer.borderWidth = 1
        NavigationBarView.layer.borderColor = UIColor(red:164/255.0, green:164/255.0, blue:164/255.0, alpha: 1.0).CGColor
        
        
    }
}
