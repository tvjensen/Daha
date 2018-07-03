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
    
    struct PostedItem {
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
    
    struct PostedRequest {
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
    
    struct Activity {
        var activityID: String
        var time: Double
        var type: String // postReq / removeReq / postItem / removeItem / sentReq / borrowed / returned
        var email: String
        var otherUserEmail: String
//        var image:  //TODO once i get around to figuring out images
        
        var firebaseDict: [String : Any] {
            let dict: [String : Any] = [
                "time": self.time,
                "type": self.type,
                "email": self.email,
                "otherUserEmail": self.otherUserEmail
            ]
            return dict
        }
        
        init?(dict: [String: Any?]) {
            guard let activityID = dict["activityID"] as? String else { return nil }
            self.activityID = activityID
            self.time = dict["time"] as! Double
            self.type = dict["type"] as! String
            self.email = dict["email"] as! String
            self.otherUserEmail = dict["otherUserEmail"] as! String
        }
    }
}
