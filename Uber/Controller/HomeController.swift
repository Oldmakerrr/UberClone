//
//  HomeController.swift
//  Uber
//
//  Created by Apple on 12.06.2022.
//

import UIKit
import Firebase
import MapKit

class HomeController: UIViewController {
    
    //MARK: - Properties
    
    private let locationManager = CLLocationManager()
    
    private let mapView = MKMapView()
    
    private let locationInputActivationView = LocationInputActivationView()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkIfUserIsLoggedIn()
        enableLocationServices()
        //signOut()
    }
    
    //MARK: - API
    
    private func checkIfUserIsLoggedIn() {
        if let uid = Auth.auth().currentUser?.uid {
            print("DEBUG: user id is \(uid)")
            configureUI()
        } else {
            goToLoginController()
            print("DEBUG: user is not logged on")
        }
    }
    
    private func signOut() {
        do {
            try Auth.auth().signOut()
            print("DEBUG: Succesfully sign out")
        } catch let error {
            print("DEBUG: Erorr signing out \(error.localizedDescription)")
        }
    }
    
    //MARK: - Helper function
    
    private func goToLoginController() {
        let loginController = LoginController()
        loginController.delegate = self
        let navigationController = UINavigationController(rootViewController: loginController)
        present(navigationController, animated: true)
    }
    
    private func configureUI() {
        configureMapUI()
        view.addSubview(locationInputActivationView)
        locationInputActivationView.delegate = self
        locationInputActivationView.centerX(inView: view)
        locationInputActivationView.setDimensions(height: 50, width: view.frame.width - 64)
        locationInputActivationView.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: view.frame.height/40)
        
        locationInputActivationView.alpha = 0
        UIView.animate(withDuration: 2) {
            self.locationInputActivationView.alpha = 1
        }
    }
    
    private func configureMapUI() {
        view.addSubview(mapView)
        mapView.frame = view.frame
        
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
    }
}

//MARK: - AccountControllersDelegates

extension HomeController: LoginControllerDelegate, SignUpViewControllerDelegate {
    
    func didComplete(_ loginController: LoginController) {
        configureUI()
    }
    
    func didComplete(_ signUpViewController: SignUpViewController) {
        configureUI()
    }
}

extension HomeController: LocationInputActivationViewDelegate {
    
    func presentLocationInputView(_ locationInputActivationView: LocationInputActivationView) {
        print("work delegate")
    }
    
}

//MARK: - LocationServices

extension HomeController: CLLocationManagerDelegate {
    
    func enableLocationServices() {
        locationManager.delegate = self
        
        switch locationManager.authorizationStatus {
        case .notDetermined:
            print("DEBUG: Not determined..")
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            print("DEBUG: Auth restricted..")
        case .denied:
            break
        case .authorizedAlways:
            print("DEBUG: Auth always..")
            locationManager.startUpdatingLocation()
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
        case .authorizedWhenInUse:
            print("DEBUG: Auth when in use..")
            locationManager.requestAlwaysAuthorization()
        @unknown default:
            break
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse {
            locationManager.requestAlwaysAuthorization()
        }
    }
}


