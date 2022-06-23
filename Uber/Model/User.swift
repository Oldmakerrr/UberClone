//
//  User.swift
//  Uber
//
//  Created by Apple on 13.06.2022.
//

import CoreLocation

struct User {
    
    let uid: String
    let fullname: String
    let email: String
    let accountType: Int
    var location: CLLocation?
    
    init(uid: String, dictionary: [String: Any]) throws {
        self.uid = uid
        if let fullname = dictionary["fullname"] as? String {
            self.fullname = fullname
        } else {
            throw Err(message: "create User failed: fullname not found")
        }
        if let email = dictionary["email"] as? String {
            self.email = email
        } else {
            throw Err(message: "create User failed: email not found")
        }
        if let accountType = dictionary["accountType"] as? Int {
            self.accountType = accountType
        } else {
            throw Err(message: "create User failed: accountType not found")
        }
//        self.fullname = dictionary["fullname"] as? String ??
//        self.email = dictionary["email"] as? String ?? ""
//        self.accountType = dictionary["accountType"] as? Int ?? 0
    }
}
