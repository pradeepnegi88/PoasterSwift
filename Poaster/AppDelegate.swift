//
//  AppDelegate.swift
//  poaster
//
//  Created by Vinod Sobale on 12/26/15.
//  Copyright © 2015 Vinod Sobale. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics
import TwitterKit
import FBSDKCoreKit
import IQKeyboardManagerSwift
import SwiftyJSON
import UserNotifications

import Firebase
import FirebaseInstanceID
import FirebaseMessaging


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    let prefs = NSUserDefaults.standardUserDefaults()
    
    var window: UIWindow?
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        
        if url.scheme == "poasterapp" {
            window?.rootViewController?.performSegueWithIdentifier("ResetPasswordSegue", sender: nil)
            return true
        }
        
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
        
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        self.prefs.setValue(false, forKey: "weekly_notification")
        
        // NOTIFICATION BADGE SETTINGS
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
        
        
        
        // Changed the font size of navigation item across the app
        let font = UIFont(name: "ProximaNova-Regular", size: 18)
        UIBarButtonItem.appearance().setTitleTextAttributes([NSFontAttributeName: font!], forState: UIControlState.Normal)
        
        IQKeyboardManager.sharedManager().enable = true
        
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        
        // Get Main StoryBoard for app
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        var initialViewController:UIViewController
        
        /*check for authtoken , as if authtoken is there ,means user was already logged in, so no need to re-login again*/
        
        let registration_complete = prefs.boolForKey("registration_completed")
        
        if registration_complete {
            initialViewController = storyboard.instantiateViewControllerWithIdentifier("loginNavigationVC") as! UINavigationController
            
        } else {
            
            let STEPNUMBER = prefs.integerForKey("step_number")
            print("my step number is \(STEPNUMBER)")
            
            if STEPNUMBER == 1 {
                print("satisfied \(STEPNUMBER)")
                // PoasterIntroView
                
                let PoasterIntroVC = storyboard.instantiateViewControllerWithIdentifier("PoasterIntroView") as! FreeTrialViewController
                
                initialViewController = UINavigationController(rootViewController: PoasterIntroVC)
                
            } else if STEPNUMBER == 2 {
                
                let PoasterIntroVC = storyboard.instantiateViewControllerWithIdentifier("PoasterIntroView") as! FreeTrialViewController
                
                initialViewController = UINavigationController(rootViewController: PoasterIntroVC)
                
            } else {
                
                /*User is new to app, so display Initial screen with create account and login options*/
                initialViewController = storyboard.instantiateViewControllerWithIdentifier("initialVC")
            }
        }
        self.window?.rootViewController = initialViewController
        self.window?.makeKeyAndVisible()
        
        
        Fabric.with([Twitter.self, Crashlytics.self])
        
        return true
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        FBSDKAppEvents.activateApp()
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
    // Redirecting User Based on the Push Notification Meta Data
    func redirectUserToViewController(storyBoardId: String) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier(storyBoardId)
        window?.rootViewController = vc
    }
        
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        
        let UserInfo = JSON(userInfo)
        print(UserInfo)
        
        
        // WEEKLY
        if UserInfo["identifier"] == "ProfileSBView" {
            if (prefs.stringForKey("authtoken") != nil) {
                if !IsAppInActiveMode() {
                    self.prefs.setValue(true, forKey: "weekly_notification")
                    redirectUserToViewController("loginNavigationVC")
                }
            } else {
                self.prefs.setValue(true, forKey: "weekly_notification")
                redirectUserToViewController("initialVC")
            }
        }
            
            // DAILY
        else if UserInfo["identifier"] == "CameraStoryBoardID" {
            redirectUserToViewController("loginNavigationVC")
        }
    }
    
}
