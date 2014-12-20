//
//  SignupViewController.swift
//  UltraMotivator
//
//  Created by Matt Luedke on 11/25/14.
//  Copyright (c) 2014 Matt Luedke. All rights reserved.
//

import UIKit
import Alamofire

class SignupViewController: UltraMotivatorViewController {
  
  @IBOutlet var userNameField : UITextField!
  @IBOutlet var passwordField : UITextField!
  @IBOutlet var confirmPasswordField : UITextField!
  @IBOutlet var submitBtn : UIButton!
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    userNameField.becomeFirstResponder()
  }
  
  @IBAction private func promptForPassword(sender: AnyObject) {
    showPasswordGenerationDialog({
      let password = SecCreateSharedWebCredentialPassword().takeUnretainedValue()
      self.passwordField.text = password
      self.confirmPasswordField.text = password
      self.makeSignUpRequest()
    })
  }
  
  @IBAction private func signUp(sender: AnyObject) {
    makeSignUpRequest()
  }
  
  private func makeSignUpRequest() {
    
    if countElements(userNameField.text) < 5
      || countElements(passwordField.text) < 5 {
        self.fillInFieldsReminder()
        return
    }
    
    if passwordField.text != confirmPasswordField.text {
      self.fieldMatchReminder()
      return
    }
    
    let parameters = [
      "username": userNameField.text,
      "password": passwordField.text
    ]
    
    UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    submitBtn.enabled = false
    
    Alamofire.request(.POST, "https://www.mattluedke.com/ultra_motivator/api/signup.py", parameters: parameters, encoding: .JSON)
      .responseJSON { (request, response, JSON, error) in
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        self.submitBtn.enabled = true
        if let unwrappedError = error {
          self.showAlert("Error", message:unwrappedError.localizedDescription, nil)
        } else {
          if let dict = JSON as? Dictionary<String, String> {
            let username = dict["username"]
            let password = dict["password"]
            
            switch(username, password) {
            case let (.Some(username), .Some(password)):
              NSUserDefaults.standardUserDefaults().setObject(username, forKey: "username")
              NSUserDefaults.standardUserDefaults().setObject(password, forKey: "password")
              SafariKeychainManager.updateSafariCredentials(username, password: password)
              self.showAlert("Signed Up", message: "Time To Get Motivated!", {self.navigationController?.popViewControllerAnimated(true)
                return})
            default:
              if let error = dict["error"] {
                self.showAlert("Error", message: error, nil)
              }
            }
          }
        }
    }
  }
}
