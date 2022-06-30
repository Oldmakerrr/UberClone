//
//  AddLocationController.swift
//  Uber
//
//  Created by Apple on 30.06.2022.
//

import UIKit
import MapKit

class AddLocationController: UITableViewController {
    
    //MARK: - Properties
    
    private final let reuseIdentifier = "AddLocationControllerCell"
    
    private let searchBar = UISearchBar()
    
    private let searchCompleter = MKLocalSearchCompleter()
    
    private var searchResults = [MKLocalSearchCompletion]() {
        didSet { tableView.reloadData() }
    }
    
    private let type: LocationType
    
    private let location: CLLocation
    
    //MARK: - Lifecycle
    
    init(type: LocationType, location: CLLocation) {
        self.type = type
        self.location = location
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
    
    //MARK: - Helper function
    
    private func configureUI() {
        configureTableView()
        configureSearchBar()
        configureSearchCompleter()
    }
    
    private func configureTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.tableFooterView = UIView()
        tableView.rowHeight = 60
        tableView.layer.applyShadow()
        
    }
    
    private func configureSearchBar() {
        navigationItem.titleView = searchBar
        searchBar.sizeToFit()
        searchBar.delegate = self
        searchBar.placeholder = "Placeholder"
    }
    
    private func configureSearchCompleter() {
        let region = MKCoordinateRegion(center: location.coordinate,
                                        latitudinalMeters: 2000,
                                        longitudinalMeters: 2000)
        searchCompleter.region = region
        searchCompleter.delegate = self
    }
}

//MARK: - UITableViewDataSource

extension AddLocationController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: reuseIdentifier)
        let searchResult = searchResults[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = searchResult.title
        content.textProperties.font = UIFont.systemFont(ofSize: 18)
        content.secondaryText = searchResult.subtitle
        content.secondaryTextProperties.color = .lightGray
        cell.contentConfiguration = content
        return cell
    }
}

//MARK: - UISearchBarDelegate

extension AddLocationController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchCompleter.queryFragment = searchText
    }
}

//MARK: - MKLocalSearchCompleterDelegate

extension AddLocationController: MKLocalSearchCompleterDelegate {
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResults = completer.results
    }
    
}
