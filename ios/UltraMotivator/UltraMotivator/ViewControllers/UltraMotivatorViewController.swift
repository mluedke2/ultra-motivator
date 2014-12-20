//
//  UltraMotivatorViewController.swift
//  UltraMotivator
//
//  Created by Matt Luedke on 11/26/14.
//  Copyright (c) 2014 Matt Luedke. All rights reserved.
//

import UIKit

class UltraMotivatorViewController: UIViewController {
  
  var keyboardDismisser : UITapGestureRecognizer!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    keyboardDismisser = UITapGestureRecognizer(target: self, action:Selector("handleTap:"))
    view.addGestureRecognizer(keyboardDismisser)
  }
  
  func handleTap(recognizer: UITapGestureRecognizer) {
    for view in self.view.subviews as [UIView] {
      if let textField = view as? UITextField {
        textField.resignFirstResponder()
      }
    }
  }
  
  func fillInFieldsReminder() {
    let alertController = UIAlertController(title: "Error", message: "More than 5 characters in all fields, please!", preferredStyle: .Alert)
    
    let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in }
    alertController.addAction(OKAction)
    
    self.presentViewController(alertController, animated: true) {}
  }
  
  func fieldMatchReminder() {
    let alertController = UIAlertController(title: "Error", message: "Textfield entries do not match!", preferredStyle: .Alert)
    
    let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in }
    alertController.addAction(OKAction)
    
    self.presentViewController(alertController, animated: true) {}
  }
  
  func showAlert(title: String, message: String, completion: (() -> Void)?) {
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
    
    let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in }
    alertController.addAction(OKAction)
    
    self.presentViewController(alertController, animated: true, completion)
  }
  
  func showPasswordGenerationDialog(success: (() -> Void)) {
    let alertController = UIAlertController(title: "Generate Password?", message: "iOS can generate an absurdly secure password for you and store it in your keychain.", preferredStyle: .Alert)
    
    let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in }
    alertController.addAction(cancelAction)
    
    let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
      success()
    }
    alertController.addAction(OKAction)
    
    self.presentViewController(alertController, animated: true) {}
  }
}
