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
import FirebaseStorage
import FacebookCore
import FBSDKLoginKit

class Firebase {
    
    // use this to interact with db
    private static let ref = Database.database().reference()
    private static let usersRef = ref.child("users")
    private static let activitiesRef = ref.child("activities")
    
    private static let storage = Storage.storage()
    private static let storeRef = storage.reference()
    private static let imagesRef = storeRef.child("images")

    
    
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
    
    public static func loginFacebookUser(callback: @escaping (Bool) -> Void) {
        let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)

        Auth.auth().signInAndRetrieveData(with: credential) { (authResult, error) in
            if error != nil {
                print(error.debugDescription)
                print(error?.localizedDescription)
            }
            callback(true)
            let connection = GraphRequestConnection()
            connection.add(GraphRequest(graphPath: "/me", parameters: ["fields": "id, first_name, last_name, picture, email"])) { httpResponse, result in
                switch result {
                case .success(let response):
                    print("Graph Request Succeeded: \(response)")
                    let email = response.dictionaryValue!["email"] as! String
                    let validEmailLoginText = email.replacingOccurrences(of: ".", with: ",")
                    let firstName = response.dictionaryValue!["first_name"] as! String
                    let lastName = response.dictionaryValue!["last_name"] as! String
                    let imageObject = response.dictionaryValue!["picture"]! as AnyObject
                    let imageData = imageObject["data"] as AnyObject
                    let imageURL = imageData["url"] as! String
                    
                    usersRef.child("\(validEmailLoginText)").observeSingleEvent(of: .value, with: {(snapshot: DataSnapshot) in
                        if snapshot.exists() {
                            Current.user = Models.User(snapshot: snapshot) // get user metadata from DB
                            // SessionManager.storeSession(session: validEmailLoginText) // store sesh to stay logged in
                        } else {
                            var dict = ["email": validEmailLoginText,
                                        "firstName": firstName,
                                        "lastName": lastName,
                                        "imageURL": imageURL,]
                            self.usersRef.child(validEmailLoginText.lowercased()).setValue(dict) // update email for this user in the db
                            Current.user = Models.User(dict: dict)
                            // SessionManager.storeSession(session: validEmailLoginText) // store sesh to stay logged in
                        }
                    })
//                    callback(true)
                case .failed(let error):
                    print("Graph Request Failed: \(error)")
                    callback(false)
                }
            }
            connection.start()
        }
    }
    
    public static func logoutFacebookUser() {
        let loginManager = FBSDKLoginManager()
        loginManager.logOut()
    }
    
    /* Registers user by creating a user instance in both the Firebase Auth and database.
     Returns true on success.
     */
    public static func registerUser(_ emailLoginText: String, _ passwordLoginText: String, _ firstName: String, _ lastName: String, _ imageURL: String, callback: @escaping (Bool) -> Void) {
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
                                        "lastName": lastName,
                                        "imageURL": imageURL,]
                            self.usersRef.child(validEmailLoginText.lowercased()).setValue(dict) // update email for this user in the db
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
        let validEmail = (Current.user?.email)!.replacingOccurrences(of: ".", with: ",")
        let dict = ["firstName": user.firstName,
                    "lastName": user.lastName,
                    "imageURL": user.imageURL,] 
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
    
    public static func addImage(filePath: String, data: NSData, metadata: StorageMetadata, callback: @escaping (Bool) -> Void) {
        imagesRef.child(filePath).putData(data as Data, metadata: metadata){(metaData,error) in
            if let error = error {
                print(error.localizedDescription)
                callback(false)
            }else{
                //store downloadURL
                let downloadURL = metaData!.downloadURL()!.absoluteString
                //store downloadURL at database
                self.usersRef.child((Current.user?.email)!).updateChildValues(["imageURL": downloadURL])
                callback(true)
            }
            
        }
    }
    
    public static func fetchProfileImage(callback: @escaping(UIImage) -> Void) {
        usersRef.child((Current.user?.email)!).observeSingleEvent(of: .value, with: { (snapshot) in
            // check if user has photo
            let value = snapshot.value as? NSDictionary
            if value!["imageURL"] as! String != "" {
                // set image locatin
                let filePath = "\((Current.user?.email)!)/\("profileImage")"
                // Assuming a < 10MB file, though you can change that
                imagesRef.child(filePath).getData(maxSize: 10*1024*1024, completion: { (data, error) in
                    if (data != nil) {
                        let userPhoto = UIImage(data: data!)
                        callback(userPhoto!)
                    }
                })
            }
        })
    }
    
    //TODO - user 'activityRef' defined above
    public static func saveActivity(activity: Models.Activity) {
        
    }
    
    
}
