//
//  Register.swift
//  Daha
//
//  Created by Thomas Jensen on 6/28/18.
//  Copyright © 2018 Thomas Jensen. All rights reserved.
//

import UIKit

class Register: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var retypePassField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var usernameAlert: UILabel!
    @IBOutlet weak var infoMessage: UILabel!
    var usernameAvailable = true
    
    override func viewDidLoad() {
        infoMessage.textColor = UIColor.white
        infoMessage.text = " "
        firstNameField.delegate = self
        lastNameField.delegate = self
        emailField.delegate = self
        passwordField.delegate = self
        retypePassField.delegate = self
        usernameField.delegate = self
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func checkUsername() {
//        Firebase.checkUsernameUnique(username: (usernameField.text?.lowercased())!) { exists in
//            if exists {
//                self.usernameAlert.text = "Sorry, that username is already taken!"
//                self.usernameAlert.textColor = UIColor.red
//                self.usernameAvailable = false
//            } else {
//                self.usernameAlert.text = "That username is available!"
//                self.usernameAlert.textColor = UIColor.green
//                self.usernameAvailable = true
//            }
//        }
    }
    
    @IBAction func register(_ sender: Any) {
        infoMessage.textColor = UIColor.gray
        infoMessage.text = "Registering..."

        checkUsername()
        if usernameAvailable {
            if validEmail() {
                if validPassword() {
                    signUpUser()
                } else {
                    infoMessage.textColor = UIColor.red
                    infoMessage.text = "Please check that the passwords match and are at least 6 characters long."
                }
            } else {
                infoMessage.textColor = UIColor.red
                infoMessage.text = "Please enter a valid email."
            }
        }
    }
    
    func validEmail() -> Bool {
        var email = emailField.text
        if email == "" {
            return false
        }
        let emailPattern = "[A-Z0-9a-z._%+-]+@[A-Z0-9a-z]+\\.[a-z]+"
        return NSPredicate(format: "SELF MATCHES %@", emailPattern).evaluate(with:email!.lowercased())
    }
    
    func validPassword() -> Bool {
        if passwordField.text == retypePassField.text {
            if (passwordField.text?.count)! >= 6 {
                return true
            }
        }
        return false
    }
    
    func signUpUser() {
        let emailLoginText : String = (emailField.text?.lowercased())!
        let passwordLoginText : String = passwordField.text!
        let firstNameText : String = firstNameField.text!
        let lastNameText : String = lastNameField.text!
        var imageID : String = ""
        Firebase.registerUser(emailLoginText, passwordLoginText, firstNameText, lastNameText, imageID) { success in
            if success { // successfully registered user, let them know to confirm email
                let alertController = UIAlertController(title: "Success", message: "You have been sent an email confirmation link. Please confirm your email to login.", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { [weak alertController] (_) in
                    self.performSegue(withIdentifier: "toLoginFromRegister", sender: Any?.self)
                }))
                alertController.view.tintColor = UIColor.flatWatermelonDark
                self.present(alertController, animated: true, completion: nil)
            //                SessionManager.storeSession(session: emailLoginText)
            } else { // an error occurred, could not successfully register
                let alertController = UIAlertController(title: "Error", message: "An error occurred while registering. This email may already by registered to an account. Please make sure your password is at least 6 characters long or please try again later.", preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(defaultAction)
                alertController.view.tintColor = UIColor.flatWatermelonDark
                self.infoMessage.text = "Error. This email may already by registered to an account. Please make sure your password is at least 6 characters long as well."
                self.infoMessage.textColor = UIColor.red
//                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
}
