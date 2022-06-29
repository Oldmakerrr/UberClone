//
//  MenuController.swift
//  Uber
//
//  Created by Apple on 29.06.2022.
//

import UIKit

let reuseIdentifier = "MenuControllerCell"

class MenuController: UITableViewController {
    
    //MARK: - Properties
    
    private lazy var menuHeader: MenuHeader = {
        let inset = UIScreen.main.bounds.width * 0.25
        let frame = CGRect(x: 0,
                           y: 0,
                           width: self.view.frame.width - inset,
                           height: UIScreen.main.bounds.height * 0.21)
        let view = MenuHeader(frame: frame)
        return view
    }()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configureTableView()
    }
    
    //MARK: - Selectors
    
    //MARK: - Helper Functions
    
    func configureTableView() {
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        tableView.rowHeight = 60
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.tableHeaderView = menuHeader
    }
}


extension MenuController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.text = "Menu Options"
        content.textProperties.font = UIFont.systemFont(ofSize: 20)
        cell.contentConfiguration = content
        return cell
    }
}
