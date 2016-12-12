//
//  Utilities.swift
//  Poaster
//
//  Created by Vinod Sobale on 7/2/16.
//  Copyright © 2016 Poaster LLC. All rights reserved.
//

import Foundation
import UIKit

func hexStringToUIColor (hex:String) -> UIColor {
    var cString:String = hex.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet() as NSCharacterSet).uppercaseString
    
    if (cString.hasPrefix("#")) {
        cString = cString.substringFromIndex(cString.startIndex.advancedBy(1))
    }
    
    if ((cString.characters.count) != 6) {
        return UIColor.grayColor()
    }
    
    var rgbValue:UInt32 = 0
    NSScanner(string: cString).scanHexInt(&rgbValue)
    
    return UIColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
        alpha: CGFloat(1.0)
    )
}

public class Utilities {
    
    // CREATES CUSTOM BUTTON
    class func CustomButton(Button: UIButton, BGCOLOR: String?, BORDERCOLOR: String?, TITLECOLOR: String?, CornerRadius: CGFloat, BorderWidth: CGFloat, FontName: String, FontSize: CGFloat) {
        if let BGColor = BGCOLOR {
            let SomeColor = hexStringToUIColor(BGColor)
            Button.backgroundColor = SomeColor
        } else {
            Button.backgroundColor = UIColor.clearColor()
        }
        
        if let BorderColor = BORDERCOLOR {
            let BorderColor: UIColor = hexStringToUIColor(BorderColor)
            Button.backgroundColor = BorderColor
        }
        
        if let TitleColor = TITLECOLOR {
            let TitleColor: UIColor = hexStringToUIColor(TitleColor)
            Button.setTitleColor(TitleColor, forState: UIControlState.Normal)
        }

        Button.layer.cornerRadius = CornerRadius
        Button.layer.borderWidth = BorderWidth
        Button.titleLabel!.font =  UIFont(name: FontName, size: FontSize)
        
    }
    
    
    class func CustomUITextField(TextField: UITextField) {
        let border = CALayer()
        let width = CGFloat(1.0)
        border.borderColor = UIColor.lightGrayColor().CGColor
        border.borderWidth = width
        
        border.frame = CGRect(x: 0, y: TextField.frame.size.height - width, width:  TextField.frame.size.width, height: TextField.frame.size.height)
        TextField.layer.addSublayer(border)
        TextField.layer.masksToBounds = true
    }
}

//func customRegisterButton() {
//    registerButton.backgroundColor = UIColor.clearColor()
//    registerButton.layer.cornerRadius = 5
//    registerButton.layer.borderWidth = 1
//    registerButton.titleLabel!.font =  UIFont(name: "ProximaNova-Regular", size: 18)
//    registerButton.layer.borderColor = UIColor(red: 211/255, green: 87/255, blue: 70/255, alpha: 1.0).CGColor
//    registerButton.setTitleColor(UIColor(red: 211/255, green: 87/255, blue: 70/255, alpha: 1.0), forState: UIControlState.Normal)
//}
//
//func customButton() {
//    
//    loginButton.backgroundColor = UIColor(red: 211/255, green: 87/255, blue: 70/255, alpha: 1.0)
//    loginButton.layer.cornerRadius = 4
//    loginButton.titleLabel!.font =  UIFont(name: "ProximaNova-Regular", size: 18)
//    loginButton.layer.borderColor = UIColor(red: 211/255, green: 87/255, blue: 70/255, alpha: 1.0).CGColor
//}
//
//func FacebookButton() {
//    SignUpWithFacebookButton.backgroundColor = UIColor(red: 59/255, green: 89/255, blue: 152/255, alpha: 1.0)
//    SignUpWithFacebookButton.layer.cornerRadius = 4
//    SignUpWithFacebookButton.titleLabel!.font =  UIFont(name: "ProximaNova-Regular", size: 14)
//}
