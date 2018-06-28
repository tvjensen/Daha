//
//  Models.swift
//  Daha
//
//  Created by Thomas Jensen on 6/28/18.
//  Copyright © 2018 Thomas Jensen. All rights reserved.
//

import Foundation
import Firebase

class Models {
    
    /*
     Relation for User. Key is email. Email for login and verification.
     */
    struct User {
        var email: String
        var firstName: String
        var lastName: String
//        var username: String
        var postedItems: [String: Any] = [:]
        var postedRequests: [String: Any] = [:]

        var firebaseDict: [String : Any] {
            let dict: [String: Any] = [
//                "username": self.username,
                "firstName": self.firstName,
                "lastName": self.lastName,
                "postedItems": self.postedItems,
                "postedRequests": self.postedRequests
            ]
            return dict
        }
        
        init?(dict: [String: Any?]) {
            guard let email = dict["email"] as? String else { return nil }
            self.postedItems = dict["postedItems"] as? [String: Any] ?? [:]
            self.postedRequests = dict["postedRequests"] as? [String: Any] ?? [:]
            self.email = email
            self.firstName = dict["firstName"] as! String
            self.lastName = dict["lastName"] as! String
//            self.username = (dict["username"] as? String)!
        }
        
        init?(snapshot: DataSnapshot) {
            guard var dict = snapshot.value as? [String: Any?] else { return nil }
            dict["email"] = snapshot.key
            self.init(dict: dict)
        }
    }
    
    struct postedItem {
        var itemID: String
        var posterEmail: String
        var title: String
        
        
        var firebaseDict: [String : Any] {
            let dict: [String: Any] = [
                "title": self.title,
                "posterEmail": self.posterEmail
            ]
            return dict
        }
        
        init?(dict: [String: Any?]) {
            guard let itemID = dict["itemID"] as? String else { return nil }
            self.itemID = itemID
            self.posterEmail = dict["posterEmail"] as! String
            self.title = dict["title"] as! String
        }
        
//        init?(snapshot: DataSnapshot) {
//            guard var dict = snapshot.value as? [String: Any?] else { return nil }
//            dict["itemID"] = snapshot.key
//            self.init(dict: dict)
//        }
    }
    
    struct postedRequest {
        var requestID: String
        var posterEmail: String
        var title: String
        
        
        var firebaseDict: [String : Any] {
            let dict: [String: Any] = [
                "title": self.title,
                "posterEmail": self.posterEmail,
                ]
            return dict
        }
        
        init?(dict: [String: Any?]) {
            guard let requestID = dict["requestID"] as? String else { return nil }
            self.requestID = requestID
            self.posterEmail = dict["posterEmail"] as! String
            self.title = dict["title"] as! String
        }
    }
}
