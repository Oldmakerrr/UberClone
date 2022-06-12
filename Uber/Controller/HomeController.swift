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
    
    private let mapView = MKMapView()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkIfUserIsLoggedIn()
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
        view.addSubview(mapView)
        mapView.frame = view.frame
    }
}

extension HomeController: LoginControllerDelegate, SignUpViewControllerDelegate {
    
    func didComplete(_ loginController: LoginController) {
        configureUI()
    }
    
    func didComplete(_ signUpViewController: SignUpViewController) {
        configureUI()
    }
}


