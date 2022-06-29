//
//  ContainerController.swift
//  Uber
//
//  Created by Apple on 29.06.2022.
//

import UIKit

class ContainerController: UIViewController {
    
    //MARK: - Properties
    
    private let homeController = HomeController()
    private let menuController = MenuController()
    
    private var isExpanded = false
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backGroundColor
        configureHomeController()
        configureMenuController()
        
        print("DEBUG: HEIGHT = \(UIScreen.main.bounds.height)")
        print("DEBUG: WIDTH = \(UIScreen.main.bounds.width)")
    }
    
    //MARK: - Selectors
    
    //MARK: - Helper Functions
    
    private func configureHomeController() {
        homeController.delegate = self
        addChild(homeController)
        homeController.didMove(toParent: self)
        view.addSubview(homeController.view)
        homeController.view.frame = view.frame
        
    }
    
    private func configureMenuController() {
        addChild(menuController)
        menuController.didMove(toParent: self)
        view.insertSubview(menuController.view, at: 0)
        menuController.view.frame = view.frame
    }
    
    private func animateMenu(shouldExpand: Bool) {
        if shouldExpand {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut) {
                let inset = UIScreen.main.bounds.width * 0.25
                self.homeController.view.frame.origin.x = self.view.frame.width - inset
            }
        } else {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut) {
                self.homeController.view.frame.origin.x = 0
            }
        }
    }
}


extension ContainerController: HomeControllerDelegate {
    
    func handleMenuToggle(_ homeController: HomeController) {
        isExpanded.toggle()
        animateMenu(shouldExpand: isExpanded)
    }
    
    
}
