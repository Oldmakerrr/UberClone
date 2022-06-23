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
let REF_TRIPS = DB_REF.child("trips")

struct Service {
    
    static let shared = Service()
    
    func fetchUserData(uid: String, complition: @escaping(User) -> Void) {
        REF_USERS.child(uid).observeSingleEvent(of: .value) { snapshot in
            guard let dictionary = snapshot.value as? [String: Any] else { return }
                if let user = try? User(uid: uid, dictionary: dictionary) {
                    complition(user)
                } else {
                    print("DEBUG: Create User failed")
                }
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
    
    func uploadTrip(_ pickupCoordinate: CLLocationCoordinate2D,
                    destinationCoordinate: CLLocationCoordinate2D,
                    complition: @escaping(Error?, DatabaseReference) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let pickupArray = [pickupCoordinate.latitude, pickupCoordinate.longitude]
        let destinationArray = [destinationCoordinate.latitude, destinationCoordinate.longitude]
        
        let values = ["pickupCoordinates" : pickupArray,
                      "destinationCoordinates" : destinationArray,
                      "state": TripState.requested.rawValue] as [String : Any]
        
        REF_TRIPS.child(uid).updateChildValues(values, withCompletionBlock: complition)
    
    }
}
