//
//  CallToActionViewController.swift
//  poaster
//
//  Created by Vinod Sobale on 12/30/15.
//  Copyright © 2015 Vinod Sobale. All rights reserved.
//

import UIKit

class CallToActionViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var ctaPicker: UIPickerView!
    
    @IBOutlet weak var BackgroundImageView: UIImageView!

    var receivedBizType: String! = nil
    var receivedBizName: String! = nil
    
    var ctaData = ["Call Now", "Book Now", "Check It Out"]
    
    // Businesses Dictionary
    
    var business: [String: String] = ["Beauty": "biztype_barber_shop.jpg", "Fashion": "biztype_shoe_store.jpg", "Fitness": "biztype_fitness.jpg", "Food Service": "biztype_restaurant.jpg", "Arts/Crafts": "biztype_ceramic.jpg", "Other-service": "biztype_tattoo_shop.jpg", "Other-goods": "biztype_music_store.jpg"]
    
    var currentSelection: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.ctaPicker.delegate = self
        self.ctaPicker.dataSource = self
        
        // This is to display Background picture
        // displayBizBackground()
        customFontUtils()
        
        let logoImage:UIImage = UIImage(named: "camera-logo.png")!
        self.navigationItem.titleView = UIImageView(image: logoImage)
        print(receivedBizName)
        
        // Setting first option of the Pickerview as selected
        currentSelection = ctaData[0]
        
        self.navigationController!.navigationBar.tintColor = UIColor(red: 152/256, green: 201/256, blue: 64/256, alpha: 1.0)
        
        // Changing the case of the Back link
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "BACK", style: .Plain, target: nil, action: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let logButton : UIBarButtonItem = UIBarButtonItem(title: "NEXT", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(CallToActionViewController.chooseCallToAction))
        self.navigationItem.rightBarButtonItem = logButton
    }
    
    func customFontUtils() {
        if let font = UIFont(name: "ProximaNova-Regular", size: 18) {
            UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName: font]
        }
    }
    
//    func displayBizBackground() {
//        for (key, value) in business {
//            if key == receivedBizType {
//                print("User chose \(value)")
//                let bgImage = UIImage(named: value)
//                self.BackgroundImageView.image = bgImage
//                break
//            }
//        }
//    }
    
    func chooseCallToAction() {
        
        let FinalActionVC = self.storyboard?.instantiateViewControllerWithIdentifier("FinalActionView") as! FinalActionViewController
        FinalActionVC.bizName = receivedBizName
        FinalActionVC.selectedCallToAction = currentSelection
        self.navigationController?.pushViewController(FinalActionVC, animated: true)
        
//        let DecisionVC = self.storyboard?.instantiateViewControllerWithIdentifier("DecisionSBView") as! DecisionViewController
//        
//        DecisionVC.BusinessTitle = receivedBizName
//        
//        DecisionVC.MarketingDecision = currentSelection
//        
//        self.navigationController?.pushViewController(DecisionVC, animated: true)
        
    }
    
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return ctaData.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return ctaData[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print(ctaData[row])
        currentSelection = ctaData[row]
    }
    
    func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let titleData = ctaData[row]
        let myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName:UIFont(name: "Helvetica Neue", size: 15.0)!,NSForegroundColorAttributeName:UIColor.blackColor()])
        return myTitle
    }
    
}
