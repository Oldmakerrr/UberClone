//
//  ContainerController.swift
//  Uber
//
//  Created by Apple on 29.06.2022.
//

import UIKit
import Firebase

class ContainerController: UIViewController {
    
    //MARK: - Properties
    
    private var homeController: HomeController!
    private var menuController: MenuController!
    
    private var isExpanded = false
    
    private var user: User? {
        didSet {
            guard let user = user else { return }
            configureHomeController(withUser: user)
            configureMenuController(withUser: user)
            shouldPresentLoadingView(false)
        }
    }
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backGroundColor
        fetchCurrentUserData()
        shouldPresentLoadingView(true, message: "Loading User Data..")
        
        print("DEBUG: HEIGHT = \(UIScreen.main.bounds.height)")
        print("DEBUG: WIDTH = \(UIScreen.main.bounds.width)")
    }
    
    //MARK: - Selectors
    
    //MARK: - API
    
    func fetchCurrentUserData() {
        guard let uid = Auth.auth().currentUser?.uid else {
            DispatchQueue.main.async {
                self.goToLoginController()
            }
            return
        }
        Service.shared.fetchUserData(uid: uid) { user in
            self.user = user
        }
    }
    
    private func signOut() {
        do {
            try Auth.auth().signOut()
            DispatchQueue.main.async {
                self.goToLoginController()
            }
            print("DEBUG: Succesfully sign out")
        } catch let error {
            print("DEBUG: Erorr signing out \(error.localizedDescription)")
        }
    }
    
    //MARK: - Navigation function
    
    private func goToLoginController() {
        let loginController = LoginController()
        let navigationController = UINavigationController(rootViewController: loginController)
        navigationController.modalPresentationStyle = .overFullScreen
        present(navigationController, animated: true)
    }
    
    //MARK: - Helper Functions
    
    private func configureHomeController(withUser user: User) {
        homeController = HomeController(user: user)
        homeController.delegate = self
        addChild(homeController)
        homeController.didMove(toParent: self)
        view.addSubview(homeController.view)
        homeController.view.frame = view.frame
        
    }
    
    private func configureMenuController(withUser user: User) {
        menuController = MenuController(user: user)
        menuController.delegate = self
        addChild(menuController)
        menuController.didMove(toParent: self)
        view.insertSubview(menuController.view, at: 0)
        menuController.view.frame = view.frame
    }
    
    private func animateMenu(shouldExpand: Bool, completion: ((Bool)->Void)? = nil) {
        var origin: CGFloat
        if shouldExpand {
            let inset = UIScreen.main.bounds.width * 0.25
            origin = self.view.frame.width - inset
        } else {
            origin = 0
        }
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
            self.homeController.view.frame.origin.x = origin
        }, completion: completion)
    }
    
    private func logOut() {
        let alert = UIAlertController(title: nil,
                                      message: "Are you sure you want to log out?",
                                      preferredStyle: .actionSheet)
        let actionLogout = UIAlertAction(title: "Log Out", style: .destructive) { _ in
            self.view.subviews.forEach{ view in
                view.removeFromSuperview()
            }
            self.signOut()
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(actionLogout)
        alert.addAction(cancel)
        self.present(alert, animated: true)
    }
    
}

//MARK: - HomeControllerDelegate

extension ContainerController: HomeControllerDelegate {
    
    func handleMenuToggle(_ homeController: HomeController) {
        isExpanded.toggle()
        animateMenu(shouldExpand: isExpanded)
    }
    
}

//MARK: - MenuControllerDelegate

extension ContainerController: MenuControllerDelegate {
    
    func didSelect(option: MenuOptions) {
        isExpanded.toggle()
        animateMenu(shouldExpand: isExpanded) { _ in
            switch option {
            case .yourTrips:
                break
            case .settings:
                break
            case .logout:
                self.logOut()
            }
        }
    }
    
}
