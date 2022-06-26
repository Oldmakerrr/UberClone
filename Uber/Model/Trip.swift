//
//  Trip.swift
//  Uber
//
//  Created by Apple on 24.06.2022.
//

import CoreLocation

struct Err: Error {
    let message: String
}

enum TripState: Int {
    case requested
    case accepted
    case driverArrived
    case inProgress
    case completed
}

struct Trip {
    
    let pickupCoordinates: CLLocationCoordinate2D
    let destinationCoordinates: CLLocationCoordinate2D
    let passangerUid: String
    var drivarUid: String?
    var state: TripState
    
    init(passangerUid: String, dictionary: [String : Any]) throws {
        self.passangerUid = passangerUid
        if let pickupCoordinates = dictionary["pickupCoordinates"] as? NSArray {
            guard let latitude = pickupCoordinates[0] as? CLLocationDegrees,
                  let longitude = pickupCoordinates[1] as? CLLocationDegrees else { throw Err(message: "Create trip failed: pickupCoordinates - latitude, longitude not found") }

            self.pickupCoordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude )
        } else {
            throw Err(message: "Create trip failed: pickupCoordinates - not found")
        }
        if let destinationCoordinates = dictionary["destinationCoordinates"] as? NSArray {
            guard let latitude = destinationCoordinates[0] as? CLLocationDegrees,
                  let longitude = destinationCoordinates[1] as? CLLocationDegrees else { throw Err(message: "Create trip failed: destinationCoordinates - latitude, longitude not found") }
            
            self.destinationCoordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude )
        } else {
            throw Err(message: "Create trip failed: destinationCoordinates - not found")
        }
        self.drivarUid = dictionary["driverUid"] as? String
        if let value = dictionary["state"] as? Int, let state = TripState(rawValue: value) {
            self.state = state
        } else {
            throw Err(message: "Create trip failed: state - not found")
        }
    }
}


