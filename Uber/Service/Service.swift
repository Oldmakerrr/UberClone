//
//  Service.swift
//  Uber
//
//  Created by Apple on 13.06.2022.
//

import Firebase

let DB_REF = Database.database().reference()
let REF_USERS = DB_REF.child("users")

struct Service {
    
    static let shared = Service()
    
    let currentUid = Auth.auth().currentUser?.uid
    
    func fetchUserData(complition: @escaping(String) -> Void) {
        guard let uid = currentUid else { return }
        REF_USERS.child(uid).observeSingleEvent(of: .value) { snapshot in
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            if let fullname = dictionary["fullname"] as? String {
                print("DEBUG: User fullname is \(fullname)")
                complition(fullname)
            }
        }
    }
    
    /*
    func fetchUserData1() -> String? {
        guard let uid = currentUid else { return nil }
        var name = String()
        REF_USERS.child(uid).observeSingleEvent(of: .value) { snapshot in
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            if let fullname = dictionary["fullname"] as? String {
                print("DEBUG: User fullname is \(fullname)")
                name = fullname
            }
        }
        return name
    }
     */
}
