//
//  SafariKeychainManager.swift
//  UltraMotivator
//
//  Created by Matt Luedke on 11/26/14.
//  Copyright (c) 2014 Matt Luedke. All rights reserved.
//

import Foundation

class SafariKeychainManager {
    
    class func checkSafariCredentialsWithCompletion(completion: ((username: String?, password: String?) -> Void)) {
        
        let domain: CFString = "mattluedke.com"
        
        SecRequestSharedWebCredential(domain, .None, {
            (credentials: CFArray!, error: CFError?) -> Void in
            
            if let unwrappedError = error {
                println("error: \(unwrappedError)")
                completion(username: nil, password: nil)
            } else if CFArrayGetCount(credentials) > 0 {
                let unsafeCred = CFArrayGetValueAtIndex(credentials, 0)
                let credential: CFDictionaryRef = unsafeBitCast(unsafeCred, CFDictionaryRef.self)
                let dict: Dictionary<String, String> = credential as Dictionary<String, String>
                let username = dict[kSecAttrAccount as String]
                let password = dict[kSecSharedPassword.takeRetainedValue() as String]
                dispatch_async(dispatch_get_main_queue()) {
                    completion(username: username, password: password)
                }
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    completion(username: nil, password: nil)
                }
            }
        });
    }
    
    class func updateSafariCredentials(username: String, password: String) {
        
        let domain = "mattluedke.com" as CFString
        
        SecAddSharedWebCredential(domain,
            username as CFString,
            password as CFString,
            {(error: CFError!) -> Void in
             println("error: \(error)")
        });
    }
}
