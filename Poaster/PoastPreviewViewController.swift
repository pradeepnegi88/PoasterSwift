//
//  PoastPreviewViewController.swift
//  poaster
//
//  Created by Vinod Sobale on 1/3/16.
//  Copyright © 2016 Vinod Sobale. All rights reserved.
//

import UIKit

class PoastPreviewViewController: UIViewController {
    
    @IBOutlet weak var PoastPreviewTitle: UILabel!
    @IBOutlet weak var PoastPreviewDescription: UILabel!
    
    @IBOutlet weak var PreviewImage: UIImageView!
    @IBOutlet weak var CTAImageView: UIImageView!
    @IBOutlet weak var OnePayPrice: UILabel!
    @IBOutlet weak var OnePayQuantity: UILabel!
    
    var receivedCTAImage: UIImage? = nil
    var receivedPreviewImage: UIImage? = nil
    var receivedTitle: String? = nil
    var receivedDescription: String? = nil
    var receivedPhoneNumber:String? = nil
    var receivedCTAName: String! = nil
    var receivedPrice: String? = nil
    var receivedQuantity: String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        PoastPreviewTitle.lineBreakMode = NSLineBreakMode.ByWordWrapping
        PoastPreviewDescription.lineBreakMode = NSLineBreakMode.ByWordWrapping
        OnePayPrice.lineBreakMode = NSLineBreakMode.ByWordWrapping
        OnePayQuantity.lineBreakMode = NSLineBreakMode.ByWordWrapping
        
        PoastPreviewTitle.numberOfLines = 0
        PoastPreviewDescription.numberOfLines = 0
        
        PreviewImage.image = receivedPreviewImage
        CTAImageView.image = receivedPreviewImage
        PoastPreviewTitle.text = receivedTitle
        PoastPreviewDescription.text = receivedDescription
        
        if receivedPrice != nil && receivedQuantity != nil {
            
            OnePayPrice.numberOfLines = 0
            OnePayQuantity.numberOfLines = 0
            
            print("received price and quantity")
            if receivedDescription == "" {
                print("didnt receive description")
                PoastPreviewDescription.text = "Price: " + receivedPrice!
                OnePayQuantity.text = "Available Stock: " + receivedQuantity!
            } else {
                OnePayPrice.text = "Price: " + receivedPrice!
                OnePayQuantity.text = "Available Stock: " + receivedQuantity!
            }
        }
        
        if receivedCTAName == "call_now" {
            CTAImageView.image = UIImage(named: "call-now.png")
        } else if receivedCTAName == "reservation" {
            if receivedPhoneNumber == "" {
                CTAImageView.image = UIImage(named: "book-now.png")
            } else {
                CTAImageView.image = UIImage(named: "book-now-phone.png")
            }
        } else if receivedCTAName == "check_it_out" {
           CTAImageView.image = UIImage(named: "check-it-out.png")
        } else {
            CTAImageView.image = UIImage(named: "buy-now.png")
        }
        
        // Adding cournded corners to the image view
        PreviewImage.layer.cornerRadius = CGRectGetWidth(PreviewImage.frame)/26.0
        PreviewImage.clipsToBounds = true
        
        let logoImage:UIImage = UIImage(named: "camera-logo.png")!
        self.navigationItem.titleView = UIImageView(image: logoImage)
        
        // Changing the case of the Back link
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "BACK", style: .Plain, target: nil, action: nil)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let logButton : UIBarButtonItem = UIBarButtonItem(title: "LOOKS GOOD", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(PoastPreviewViewController.selectSocialNetwork))
        self.navigationItem.rightBarButtonItem = logButton
    }
    
    func selectSocialNetwork() {
        
        let SelectSocialVC = self.storyboard?.instantiateViewControllerWithIdentifier("SocialView") as! SocialViewController
        self.navigationController!.pushViewController(SelectSocialVC, animated: true)
    }
    
}
