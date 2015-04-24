//
//  LoginViewController.swift
//  UltraMotivator
//
//  Created by Matt Luedke on 11/11/14.
//  Copyright (c) 2014 Matt Luedke. All rights reserved.
//

import UIKit
import Alamofire

class LoginViewController: UltraMotivatorViewController {
  
  @IBOutlet var userNameField : UITextField!
  @IBOutlet var passwordField : UITextField!
  @IBOutlet var submitBtn : UIButton!
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    userNameField.becomeFirstResponder()
    
    SafariKeychainManager.checkSafariCredentialsWithCompletion({
      (username: String?, password: String?) -> Void in
      switch(username, password) {
      case let (.Some(username), .Some(password)):
        self.userNameField.text = username
        self.passwordField.text = password
        self.makeSignInRequest(false)
      default:
        break
      }
    })
  }
  
  private func makeSignInRequest(updateKeychain:Bool) {
    
    if count(userNameField.text) < 5
      || count(passwordField.text) < 5 {
        fillInFieldsReminder()
        return
    }
    
    let parameters = [
      "username": userNameField.text,
      "password": passwordField.text
    ]
    
    UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    submitBtn.enabled = false
    
    Alamofire.request(.POST, "https://www.mattluedke.com/ultra_motivator/api/signin.py", parameters: parameters, encoding: .JSON)
      .responseJSON { (request, response, JSON, error) in
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        self.submitBtn.enabled = true
        if let error = error {
          self.showAlert("Error", message: error.localizedDescription, completion: nil)
        } else {
          if let dict = JSON as? Dictionary<String, String> {
            let username = dict["username"]
            let password = dict["password"]
            
            switch(username, password) {
            case let (.Some(username), .Some(password)):
              NSUserDefaults.standardUserDefaults().setObject(username, forKey: "username")
              NSUserDefaults.standardUserDefaults().setObject(password, forKey: "password")
              if (updateKeychain) {
                SafariKeychainManager.updateSafariCredentials(username, password: password)
              }
              self.showAlert("Logged In", message: "Time To Get Motivated!", completion: {self.navigationController?.popViewControllerAnimated(true)
                return
              })
            default:
              if let error = dict["error"] {
                self.showAlert("Error", message: error, completion: nil)
              }
            }
          }
        }
    }
  }
  
  @IBAction private func signIn(sender: AnyObject) {
    makeSignInRequest(true)
  }
}

