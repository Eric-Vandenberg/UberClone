//
//  ViewController.swift
//
//  Copyright 2011-present Parse Inc. All rights reserved.
//

import UIKit
import Parse

class ViewController: UIViewController, UITextFieldDelegate {
    
    
    var signUpState = true
    
    func displayAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            alert.dismissViewControllerAnimated(true, completion: nil)
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    
    @IBOutlet weak var username: UITextField!
    
    @IBOutlet weak var password: UITextField!
    
    @IBOutlet weak var `switch`: UISwitch!
    
    @IBOutlet weak var driverLabel: UILabel!
    
    @IBOutlet weak var riderLabel: UILabel!
    
    @IBOutlet weak var signUpButton: UIButton!
    
    @IBOutlet weak var toggleSignUpButton: UIButton!
    

    @IBAction func signUp(sender: AnyObject) {
        
        if username.text == "" || password.text == "" {
            
            displayAlert("Missing Field(s)", message: "Username and Password are required")
            
        } else {
            
            if signUpState == true {
                
                var user = PFUser()
                user.username = username.text
                user.password = password.text
            
                user["isDriver"] = `switch`.on
                
                user.signUpInBackgroundWithBlock {
                    (success, error) -> Void in
                    if let error = error {
                        
                        if let errorString = error.userInfo["error"] as? String {
                        
                            self.displayAlert("Sign Up Failed", message: errorString)
                            
                        }
                        
                    } else {
                        
                        if self.`switch`.on == true {
                            
                            self.performSegueWithIdentifier("loginDriver", sender: self)
                            
                        } else {
                        
                            self.performSegueWithIdentifier("loginRider", sender: self)
                        
                        }
                    
                    }
                }
                
            } else {
            
                PFUser.logInWithUsernameInBackground(username.text!, password: password.text!) {
                    (user: PFUser?, error: NSError?) -> Void in
                    
                    if let user = user {
                    
                        if user["isDriver"]! as! Bool == true {
                            
                            self.performSegueWithIdentifier("loginDriver", sender: self)
                            
                        } else {
                            
                            self.performSegueWithIdentifier("loginRider", sender: self)
                            
                        }
                        
                    } else {
                    
                        if let errorString = error?.userInfo["error"] as? String {
                            
                            self.displayAlert("Login Failed", message: errorString)
                            
                        }
                    
                    }
                    
                }
                
            }
            
        }
        
    }


    @IBAction func toggleSignUp(sender: AnyObject) {
        
        if signUpState == true {
            
            signUpButton.setTitle("Login", forState: UIControlState.Normal)
            
            toggleSignUpButton.setTitle("switch to sign up", forState: UIControlState.Normal)
            
            signUpState = false
            
            riderLabel.alpha = 0
            driverLabel.alpha = 0
            `switch`.alpha = 0
        
        } else {
            
            signUpButton.setTitle("Sign Up", forState: UIControlState.Normal)
            
            toggleSignUpButton.setTitle("switch to login", forState: UIControlState.Normal)
            
            signUpState = true
            
            riderLabel.alpha = 1
            driverLabel.alpha = 1
            `switch`.alpha = 1
            
        }
        
    }


    

    override func viewDidLoad() {
        super.viewDidLoad()
    
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DismissKeyboard")
        view.addGestureRecognizer(tap)
        
        self.username.delegate = self
        self.password.delegate = self
        
    }
    
    override func viewDidAppear(animated: Bool) {
        
        if PFUser.currentUser()?.username != nil {
            
            if PFUser.currentUser()?["isDriver"]! as! Bool == true {
                
                self.performSegueWithIdentifier("loginDriver", sender: self)
                
            } else {
                
                self.performSegueWithIdentifier("loginRider", sender: self)
                
            }
            
        }
        
    }
    
    //Calls this function when the tap is recognized.
    func DismissKeyboard(){
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        return true
    }
    
}

