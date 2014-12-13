//
//  HomeViewController.swift
//  UltraMotivator
//
//  Created by Matt Luedke on 11/25/14.
//  Copyright (c) 2014 Matt Luedke. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    
    @IBOutlet var titleLabel : UILabel!
    @IBOutlet var signInButton : UIButton!
    @IBOutlet var signUpButton : UIButton!
    @IBOutlet var signOutButton : UIButton!
    @IBOutlet var updateButton : UIButton!
    @IBOutlet var motivateButton : UIButton!

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.resetUI()
    }
    
    private func resetUI() {
        if let unwrappedUsername = NSUserDefaults.standardUserDefaults().objectForKey("username") as? String {
            signInButton.hidden = true;
            signUpButton.hidden = true;
            signOutButton.hidden = false;
            updateButton.hidden = false;
            motivateButton.hidden = false;
            titleLabel.text = "You're signed in as \(unwrappedUsername)!"
        } else {
            signInButton.hidden = false;
            signUpButton.hidden = false;
            signOutButton.hidden = true;
            updateButton.hidden = true;
            motivateButton.hidden = true;
            titleLabel.text = "Please Authenticate"
        }
    }
    
    @IBAction private func signOut(sender: AnyObject) {
        
        if let unwrappedUsername = NSUserDefaults.standardUserDefaults().objectForKey("username") as? String {
            SafariKeychainManager.updateSafariCredentials(unwrappedUsername, password: "")
        }
        NSUserDefaults.standardUserDefaults().removeObjectForKey("username")
        NSUserDefaults.standardUserDefaults().removeObjectForKey("password")
        
        self.resetUI()
    }
}
