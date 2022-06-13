//
//  Service.swift
//  Uber
//
//  Created by Apple on 13.06.2022.
//

import Firebase

let DB_REF = Database.database().reference()
let REF_USERS = DB_REF.child("users")
let REF_DRIVERS_LOCATION = DB_REF.child("driver-locatoins")

struct Service {
    
    static let shared = Service()
    
    func fetchUserData(complition: @escaping(User) -> Void) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        REF_USERS.child(currentUid).observeSingleEvent(of: .value) { snapshot in
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            let user = User(dictionary: dictionary)
            complition(user)
        }
    }
   
    
}
