//
//  User.swift
//  Uber
//
//  Created by Apple on 13.06.2022.
//

import CoreLocation

enum AccountType: Int {
    case passenger
    case driver
}

struct User {
    
    let uid: String
    let fullname: String
    let email: String
    let accountType: AccountType
    var location: CLLocation?
    var homeLocation: String?
    var workLocation: String?
    
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
        if let rawValue = dictionary["accountType"] as? Int, let accountType = AccountType(rawValue: rawValue) {
            self.accountType = accountType
        } else {
            throw Err(message: "create User failed: accountType not found")
        }
        if let homeLocation = dictionary[LocationType.home.description] as? String {
            self.homeLocation = homeLocation
        }
        if let workLocation = dictionary[LocationType.work.description] as? String {
            self.workLocation = workLocation
        }
    }
}
