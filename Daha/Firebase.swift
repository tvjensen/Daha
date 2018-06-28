//
//  File.swift
//  Daha
//
//  Created by Thomas Jensen on 6/26/18.
//  Copyright © 2018 Thomas Jensen. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth

class Firebase {
    
    // use this to interact with db
    private static let ref = Database.database().reference()
    private static let usersRef = ref.child("users")
    
    private static var currentTime: Double {
        return Double(NSDate().timeIntervalSince1970)
    }
    
    
    /* Logs in user by authenticating if they exist/have correct password. Returns true on success.
    */
    public static func loginUser(_ emailLoginText: String, _ passwordLoginText: String, callback: @escaping (Bool) -> Void) {
//         Firebase does not accept certain tokens such as '.' so we must encode emails by replacing dots with commas. tvjensen@stanford.edu becomes tvjensen@stanford,edu
        let validEmailLoginText =  emailLoginText.replacingOccurrences(of: ".", with: ",")
        Auth.auth().signIn(withEmail: emailLoginText.lowercased(), password: passwordLoginText) { (user, error) in
            if error == nil && (user?.isEmailVerified)! { // successfully logged in user AND user has already verified email
                print("Successful login")
                usersRef.child("\(validEmailLoginText)").observeSingleEvent(of: .value, with: {(snapshot: DataSnapshot) in
                    if snapshot.exists() {
                        Current.user = Models.User(snapshot: snapshot) // get user metadata from DB
//                        SessionManager.storeSession(session: validEmailLoginText) // store sesh to stay logged in
                        callback(true)
                    } else {
                        callback(false)
                    }
                })
            } else { // user not found or password wrong
                callback(false)
            }
        }
    }
    
    /* Registers user by creating a user instance in both the Firebase Auth and database.
     Returns true on success.
     */
    public static func registerUser(_ emailLoginText: String, _ passwordLoginText: String, _ firstName: String, _ lastName: String, callback: @escaping (Bool) -> Void) {
        // create this user Auth object (Firebase will handle salting/hashing/store the password server side
        Auth.auth().createUser(withEmail: emailLoginText.lowercased(), password: passwordLoginText) { (user, error) in
            if error == nil { // successfully created user in auth
                user?.sendEmailVerification(completion: { (error) in
                    if let error = error { // failed to send email, return false
                        print(error.localizedDescription)
                        callback(false)
                    }
                    print("Sent email verification")
                    // Firebase does not accept certain tokens such as '.' so we must encode emails by replacing dots with commas. tvjensen@stanford.edu becomes tvjensen@stanford,edu
                    let validEmailLoginText =  emailLoginText.replacingOccurrences(of: ".", with: ",")
                    // we have to create a user object for this user in the db (not in auth, which we already did with createUser( )

                    usersRef.child("\(validEmailLoginText)").observeSingleEvent(of: .value, with: {(snapshot: DataSnapshot) in
                        if snapshot.exists() {
                            callback(false)
                        } else {
                            var dict = ["email": validEmailLoginText,
                                        "firstName": firstName,
                                        "lastName": lastName]
                            self.usersRef.child(validEmailLoginText.lowercased()).setValue(dict) // update email for this user in the db
                            dict["email"] = emailLoginText
                            Current.user = Models.User(dict: dict)
                            callback(true)
                        }
                    })
                })
            } else {
                callback(false)
            }
        }
    }
    
    public static func updateCurrentUser(user: Models.User) {
        print("Updating User")
        let validEmail = Current.user?.email.replacingOccurrences(of: ".", with: ",")
        let dict = ["firstName": user.firstName,
                    "lastName": user.lastName]
        usersRef.child("\(validEmail)").setValue(dict)
        Current.user = user
    }
    
    public static func resetPassword(email: String, callback: @escaping (Bool) -> Void) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if error != nil {
                print(error?.localizedDescription)
                callback(false)
            } else {
                callback(true)
            }
        }
    }
    
//    public static func checkUsernameUnique(username: String, callback: @escaping (Bool) -> Void) {
//        usersRef.child("\(username)").observeSingleEvent(of: .value, with: {(snapshot: DataSnapshot) in
//            if snapshot.exists() {
//                callback(true)
//            } else {
//                callback(false)
//            }
//        })
//    }
    
    
}
