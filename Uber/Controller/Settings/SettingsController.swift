//
//  SettingsController.swift
//  Uber
//
//  Created by Apple on 29.06.2022.
//

import UIKit

enum LocationType: Int, CaseIterable, CustomStringConvertible {
    case home
    case work
    
    var description: String {
        switch self {
        case .home:
            return "Home"
        case .work:
            return "Work"
        }
    }
    
    var subTitle: String {
        switch self {
        case .home:
            return "Add Home"
        case .work:
            return "Add Work"
        }
    }
}

protocol SettingsControllerDelegate: AnyObject {
    func updateUser(_ settingsController: SettingsController)
}

class SettingsController: UITableViewController {
    
    //MARK: - Properties
    
    weak var delegate: SettingsControllerDelegate?
    
    var user: User
    var userInfoUpdated = false
    
    private lazy var frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 64)
    private lazy var userInfoHeader = MenuHeader(frame: frame, user: user, style: .white)
    
    private let locationManager = LocationHandler.shared.locationManager
    
    //MARK: - Lifecycle
    
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    //MARK: - Selectors
    
    @objc private func handleDismissal() {
        if userInfoUpdated {
            delegate?.updateUser(self)
        }
        dismiss(animated: true)
    }
    
    //MARK: - Helper functions
    
    private func configureUI() {
        configureTableView()
        configureNavigationBar()
    }
    
    private func configureTableView() {
        tableView.tableHeaderView = userInfoHeader
        tableView.rowHeight = 60
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "identifier")
        tableView.tableFooterView = UIView()
    }
    
    private func configureNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Settings"
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "multiply"),
                                                           style: .done,
                                                           target: self,
                                                           action: #selector(handleDismissal))
        
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.backgroundColor = .backGroundColor
            appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
            appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
            
            navigationController?.navigationBar.tintColor = .white
            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.compactAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
        } else {
            navigationController?.navigationBar.isTranslucent = false
            navigationController?.navigationBar.barStyle = .black
            navigationController?.navigationBar.tintColor = .white
            navigationController?.navigationBar.backgroundColor = .backGroundColor
        }
        
    }
    
    func locationText(forType type: LocationType) -> String {
        switch type {
        case .home:
            return user.homeLocation ?? type.subTitle
        case .work:
            return user.workLocation ?? type.subTitle
        }
    }
    
}

//MARK: - UITableViewDataSource

extension SettingsController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return LocationType.allCases.count
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .black
        
        let title = UILabel()
        title.font = UIFont.systemFont(ofSize: 16)
        title.textColor = .white
        title.text = "Favorites"
        view.addSubview(title)
        title.centerY(inView: view, leftAnchor: view.leftAnchor, paddingLeft: 16)
        return view
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "identifier", for: indexPath)
        guard let type = LocationType(rawValue: indexPath.row) else { return cell }
        var content = cell.defaultContentConfiguration()
        content.text = type.description
        content.secondaryText = locationText(forType: type)
        content.textProperties.font = UIFont.systemFont(ofSize: 18)
        content.secondaryTextProperties.color = .lightGray
        cell.contentConfiguration = content
        return cell
    }
}

//MARK: - UITableViewDelegate

extension SettingsController {
     
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let type = LocationType(rawValue: indexPath.row),
              let location = locationManager?.location else { return }
        let addLocationController = AddLocationController(type: type, location: location)
        addLocationController.delegate = self
        let navigationController = UINavigationController(rootViewController: addLocationController)
        present(navigationController, animated: true)
    }
}

//MARK: - AddLocationControllerDelegate

extension SettingsController: AddLocationControllerDelegate {
    
    func updateLocation(location: String, type: LocationType) {
        PassengerService.shared.saveLocation(location: location, type: type) { error, reference in
            self.dismiss(animated: true)
            self.userInfoUpdated = true
            switch type {
            case .home:
                self.user.homeLocation = location
            case .work:
                self.user.workLocation = location
            }
            self.tableView.reloadData()
        }
    }
}
