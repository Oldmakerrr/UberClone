//
//  Service.swift
//  Uber
//
//  Created by Apple on 13.06.2022.
//

import Firebase
import CoreLocation
import GeoFire

let DB_REF = Database.database().reference()
let REF_USERS = DB_REF.child("users")
let REF_DRIVERS_LOCATION = DB_REF.child("driver-locatoins")

struct Service {
    
    static let shared = Service()
    
    func fetchUserData(uid: String, complition: @escaping(User) -> Void) {
        REF_USERS.child(uid).observeSingleEvent(of: .value) { snapshot in
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            let user = User(uid: uid, dictionary: dictionary)
            complition(user)
        }
    }
   
    func fetchDrivers(location: CLLocation, complition: @escaping(User)-> Void) {
        let geoFire = GeoFire(firebaseRef: REF_DRIVERS_LOCATION)
        
        REF_DRIVERS_LOCATION.observe(.value) { snapshot in
            geoFire.query(at: location, withRadius: 50).observe(.keyEntered, with: { uid, location in
                fetchUserData(uid: uid) { user in
                    var driver = user
                    driver.location = location
                    complition(driver)
                }
            })
        }

    }
}
