//
//  LoginViewController.swift
//  Daha
//
//  Created by Thomas Jensen on 6/26/18.
//  Copyright © 2018 Thomas Jensen. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {

    @IBOutlet weak var emailLogin: UITextField!
    @IBOutlet weak var passwordLogin: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        passwordLogin.isSecureTextEntry = true
        // Do any additional setup after loading the view.
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
                    let alertController = UIAlertController(title: "Error", message: "Invalid email or password. Please confirm your email if you have not confirmed already.", preferredStyle: .alert)

                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
//                    alertController.view.tintColor = UIColor.flatMint
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        } else { // invalid text entry. TODO: change this to floating sky text or whatever
            let alertController = UIAlertController(title: "Error", message: "Please enter a valid email and password.", preferredStyle: .alert)

            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
//            alertController.view.tintColor = UIColor.flatMint

            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    @IBAction func signUpUser(_ sender: Any) {
        let emailLoginText : String = emailLogin.text!
        let passwordLoginText : String = passwordLogin.text!
        Firebase.registerUser(emailLoginText, passwordLoginText) { success in
            if success { // successfully registered user, let them know to confirm email
                let alertController = UIAlertController(title: "Success", message: "You have been sent an email confirmation link. Please confirm your email to login.", preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(defaultAction)
//                alertController.view.tintColor = UIColor.flatMint
                self.present(alertController, animated: true, completion: nil)
//                SessionManager.storeSession(session: emailLoginText)
            } else { // an error occurred, could not successfully register
                let alertController = UIAlertController(title: "Error", message: "An error occurred while registering. Please make sure your password is at least 6 characters long or please try again later.", preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(defaultAction)
//                alertController.view.tintColor = UIColor.flatMint
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    
    
    static func isValidEmail(_ email: String) -> Bool {
//        let emailPattern = "[A-Z0-9a-z._%+-]+@stanford\\.edu"
//        return NSPredicate(format: "SELF MATCHES %@", emailPattern).evaluate(with:email.lowercased())
        return true
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
