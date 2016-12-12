//
//  PoasterUtility.swift
//  poaster
//
//  Created by Amol Patil on 17/02/16.
//  Copyright © 2016 Vinod Sobale. All rights reserved.
//

import Foundation

class PoasterUtility {
    
    static let sharedInstance = PoasterUtility()
    
    // METHODS
 
//    func getAuthTokenValue() ->String {
//        let prefs = NSUserDefaults.standardUserDefaults()
//        let authToken = prefs.stringForKey(K_AUTH_TOKEN)
//        return authToken!
//    }
    
    func resetAuthTokenValue() {
        let prefs = NSUserDefaults.standardUserDefaults()
        prefs.removeObjectForKey(K_AUTH_TOKEN)
    }
    
    func resetAllUserDefaultsValues() {
        // resetAuthTokenValue();
        //will reset all the NSUserDefaults for an app
        NSUserDefaults.standardUserDefaults().removePersistentDomainForName(NSBundle.mainBundle().bundleIdentifier!)
    }
    
    func setUserDefaultValue(strKey:String , value :Int) {
      let prefs = NSUserDefaults.standardUserDefaults()
      prefs.setValue(value, forKey: strKey)
    }
    
    func getUserDefaultValueForKey(strKey:String) ->Int {
        let prefs = NSUserDefaults.standardUserDefaults()
        let authToken = prefs.integerForKey(strKey)
        return authToken
    }
}
