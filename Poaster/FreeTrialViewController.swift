//
//  FreeTrialViewController.swift
//  poaster
//
//  Created by Poaster.
//  Copyright © 2016 Vinod Sobale. All rights reserved.
//

import UIKit
import Foundation

protocol FreeTrialDelegate {
    func showViewController()
}

class FreeTrialViewController: UIViewController {
    
    var delegate: FreeTrialDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
    }

    
}