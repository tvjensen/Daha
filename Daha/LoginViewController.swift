//
//  LoginViewController.swift
//  Daha
//
//  Created by Thomas Jensen on 6/26/18.
//  Copyright © 2018 Thomas Jensen. All rights reserved.
//

import UIKit
import Firebase
import ChameleonFramework
import FBSDKLoginKit
import FacebookCore


class LoginViewController: UIViewController, UITextFieldDelegate, FBSDKLoginButtonDelegate {

    @IBOutlet weak var emailLogin: UITextField!
    @IBOutlet weak var passwordLogin: UITextField!
    
    @IBOutlet weak var forgotPasswordButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var facebookLoginButton: FBSDKLoginButton!
    
    var facebookLoggedIn = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        forgotPasswordButton.titleLabel?.textAlignment = NSTextAlignment.center
        self.view.backgroundColor = UIColor.flatWatermelon
        passwordLogin.isSecureTextEntry = true
        emailLogin.delegate = self
        passwordLogin.delegate = self
        facebookLoginButton.delegate = self
        facebookLoginButton.readPermissions = ["public_profile", "email"]
        if let accessToken = FBSDKAccessToken.current() {
            facebookLoggedIn = true
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("Did logout of Facebook.")
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if error != nil {
            print(error.localizedDescription)
            return
        }
        
        let connection = GraphRequestConnection()
        connection.add(GraphRequest(graphPath: "/me", parameters: ["fields": "id, first_name, last_name, picture, email"])) { httpResponse, result in
            switch result {
            case .success(let response):
                print("Graph Request Succeeded: \(response)")
                Firebase.loginFacebookUser(loggedIn: self.facebookLoggedIn, fbResponse: response) { (success) in
                    if success {
                        print("Successfully logged in with Facebook.")
                        self.performSegue(withIdentifier: "successfulLogin", sender: nil)
                    }
                }
            case .failed(let error):
                print("Graph Request Failed: \(error)")
            }
        }
        connection.start()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginUser(_ sender: Any) {
        let emailLoginText: String = emailLogin.text!
        let passwordLoginText: String = passwordLogin.text!
        if emailLoginText != "" && passwordLoginText != "" { // non-empty, attempt login
            Firebase.loginUser(emailLoginText.lowercased(), passwordLoginText) { success in
                if success { // successful login, session stored, can segue
                    print("Success in logging in user!")
                    self.performSegue(withIdentifier: "successfulLogin", sender: nil)
                } else { // failed to login because of invalid user or password
                    let alertController = UIAlertController(title: "Error", message: "Unrecognized username or password. Please check your email to verify your registration if you have not already.", preferredStyle: .alert)

                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    alertController.view.tintColor = UIColor.flatWatermelonDark
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        } else { // invalid text entry. TODO: change this to floating sky text or whatever
            let alertController = UIAlertController(title: "Error", message: "Please enter a valid username and password.", preferredStyle: .alert)

            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            alertController.view.tintColor = UIColor.flatWatermelonDark

            self.present(alertController, animated: true, completion: nil)
        }
    }
    
//    @IBAction func signUpUser(_ sender: Any) {
//        let usernameLoginText : String = usernameLogin.text!
//        let passwordLoginText : String = passwordLogin.text!
//        Firebase.registerUser(usernameLoginText, passwordLoginText) { success in
//            if success { // successfully registered user, let them know to confirm email
//                let alertController = UIAlertController(title: "Success", message: "You have been sent an email confirmation link. Please confirm your email to login.", preferredStyle: .alert)
//                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
//                alertController.addAction(defaultAction)
//                alertController.view.tintColor = UIColor.flatWatermelonDark
//                self.present(alertController, animated: true, completion: nil)
////                SessionManager.storeSession(session: emailLoginText)
//            } else { // an error occurred, could not successfully register
//                let alertController = UIAlertController(title: "Error", message: "An error occurred while registering. Please make sure your password is at least 6 characters long or please try again later.", preferredStyle: .alert)
//                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
//                alertController.addAction(defaultAction)
//                alertController.view.tintColor = UIColor.flatWatermelonDark
//                self.present(alertController, animated: true, completion: nil)
//            }
//        }
//    }
    
    @IBAction func forgotPassword(_ sender: Any) {
        let alertError = UIAlertController(title: "Something went wrong", message: "We were unable to send your reset email. Please make sure your email is associated with an exisiting account and that you entered your email correctly.", preferredStyle: UIAlertControllerStyle.alert)
        alertError.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { [weak alertError] (_) in
        }))
        alertError.view.tintColor = UIColor.flatWatermelonDark
        
        let alert = UIAlertController(title: "Forgot Password", message: "We can reset your password and send an email to you with further instructions.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addTextField(configurationHandler: {(textField: UITextField!) in
            textField.placeholder = "Your email"
        })
        alert.addAction(UIAlertAction(title: "Send email", style: UIAlertActionStyle.default, handler: { [weak alert] (_) in
            Firebase.resetPassword(email: (alert?.textFields![0].text)!) { (success) in
                if (!success) {
                    print("Error reseting password", success)
                    self.present(alertError, animated: true, completion: nil)
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "Nevermind", style: UIAlertActionStyle.default, handler: { [weak alert] (_) in
        }))
        alert.view.tintColor = UIColor.flatWatermelonDark
        
        self.present(alert, animated: true, completion: nil)
    }
}
