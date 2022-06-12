//
//  HomeController.swift
//  Uber
//
//  Created by Apple on 12.06.2022.
//

import UIKit
import Firebase

class HomeController: UIViewController {
    
    //MARK: - Properties
    
    //MARK: - Lifecycle
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkIfUserIsLoggedIn()
        view.backgroundColor = .cyan
    }
    
    //MARK: -  API
    
    func checkIfUserIsLoggedIn() {
        if let uid = Auth.auth().currentUser?.uid {
            print("DEBUG: user id is \(uid)")
        } else {
            let navigationController = UINavigationController(rootViewController: LoginController())
            present(navigationController, animated: true)
            print("DEBUG: user is not logged on")
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            print("DEBUG: Succesfully sign out")
        } catch let error {
            print("DEBUG: Erorr signing out \(error.localizedDescription)")
        }
    }
}
