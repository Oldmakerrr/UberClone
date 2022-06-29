//
//  MenuController.swift
//  Uber
//
//  Created by Apple on 29.06.2022.
//

import UIKit

enum MenuOptions: Int, CaseIterable, CustomStringConvertible {
    
    case yourTrips
    case settings
    case logout
    
    var description: String {
        switch self {
        case .yourTrips:
            return "Your Trips"
        case .settings:
            return "Settings"
        case .logout:
            return "Log Out"
        }
    }
}

protocol MenuControllerDelegate: AnyObject {
    func didSelect(option: MenuOptions)
}

class MenuController: UIViewController {
    
    //MARK: - Properties
    
    weak var delegate: MenuControllerDelegate?
    
    private let tableView = UITableView()
    
    private let cellReuseIdentifier = "MenuControllerCell"
    
    private let user: User
    
    private lazy var menuHeader: MenuHeader = {
        let inset = UIScreen.main.bounds.width * 0.25
        let frame = CGRect(x: 0,
                           y: 0,
                           width: self.view.frame.width - inset,
                           height: UIScreen.main.bounds.height * 0.21)
        let view = MenuHeader(frame: frame, user: user, style: .black)
        return view
    }()
    
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
        view.backgroundColor = .backGroundColor
        configureTableView()
    }
    
    //MARK: - Selectors
    
    //MARK: - Helper Functions
    
    func configureTableView() {
        view.addSubview(tableView)
        tableView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor,
                         bottom: view.bottomAnchor, right: view.rightAnchor)
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        tableView.rowHeight = 60
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        tableView.tableHeaderView = menuHeader
        tableView.delegate = self
        tableView.dataSource = self
    }
}


extension MenuController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MenuOptions.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath)
        guard let option = MenuOptions(rawValue: indexPath.row) else { return cell }
        var content = cell.defaultContentConfiguration()
        content.text = option.description
        content.textProperties.font = UIFont.systemFont(ofSize: 20)
        cell.contentConfiguration = content
        return cell
    }
}

extension MenuController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let option = MenuOptions(rawValue: indexPath.row) else { return }
        delegate?.didSelect(option: option)
    }
    
}
