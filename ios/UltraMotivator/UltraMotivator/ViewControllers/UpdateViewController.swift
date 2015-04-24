//
//  UpdateViewController.swift
//  UltraMotivator
//
//  Created by Matt Luedke on 11/25/14.
//  Copyright (c) 2014 Matt Luedke. All rights reserved.
//

import UIKit
import Alamofire

class UpdateViewController: UltraMotivatorViewController {
  
  @IBOutlet var passwordField : UITextField!
  @IBOutlet var confirmPasswordField : UITextField!
  @IBOutlet var submitBtn : UIButton!
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    passwordField.becomeFirstResponder()
    if (count(passwordField.text) == 0) {
        self.promptForPassword()
    }
  }
  
  private func promptForPassword() {
    showPasswordGenerationDialog({
      let password = SecCreateSharedWebCredentialPassword().takeUnretainedValue()
      self.passwordField.text = password as String
      self.confirmPasswordField.text = password as String
      self.makeUpdateRequest()
    })
  }
  
  @IBAction private func update(sender: AnyObject) {
    makeUpdateRequest()
  }
  
  private func makeUpdateRequest() {
    
    if count(passwordField.text) < 5
      || count(confirmPasswordField.text) < 5 {
        self.fillInFieldsReminder()
        return
    }
    
    if passwordField.text != confirmPasswordField.text {
      self.fieldMatchReminder()
      return
    }
    
    let parameters = [
      "username": NSUserDefaults.standardUserDefaults().objectForKey("username") as! String,
      "current_password": NSUserDefaults.standardUserDefaults().objectForKey("password") as! String,
      "new_password": passwordField.text
    ]
    
    UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    submitBtn.enabled = false
    
    Alamofire.request(.POST, "https://www.mattluedke.com/ultra_motivator/api/update.py", parameters: parameters, encoding: .JSON)
      .responseJSON { (request, response, JSON, error) in
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        self.submitBtn.enabled = true
        if let error = error {
          self.showAlert("Error", message:error.localizedDescription, completion: nil)
        } else {
          if let dict = JSON as? Dictionary<String, String> {
            let username = dict["username"]
            let password = dict["password"]
            
            switch(username, password) {
            case let (.Some(username), .Some(password)):
              NSUserDefaults.standardUserDefaults().setObject(username, forKey: "username")
              NSUserDefaults.standardUserDefaults().setObject(password, forKey: "password")
              SafariKeychainManager.updateSafariCredentials(username, password: password)
              self.showAlert("Updated", message: "Your password has been updated.", completion: {self.navigationController?.popViewControllerAnimated(true)
                return})
            default:
              if let error = dict["error"] {
                self.showAlert("Error", message: error, completion: nil)
              }
            }
          }
        }
    }
  }
}
