//
//  HomeController.swift
//  Uber
//
//  Created by Apple on 12.06.2022.
//

import UIKit
import Firebase
import MapKit

let driverAnnotationIdentifier = "DriverAnnotationIdentifier"

private enum ButtonActionConfiguration {
    case showMenu
    case dismissActionView
    
    init() {
        self = .showMenu
    }
}

class HomeController: UIViewController {
    
    //MARK: - Properties
    
    private let locationManager = LocationHandler.shared.locationManager
    
    private let mapView = MKMapView()
    
    private let locationInputActivationView = LocationInputActivationView()
    private let locationInputView = LocationInputView()
    private let rideActionView = RideActionView(typeOfUber: "x")
    
    private let actionButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(systemName: "list.bullet"), for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(actionButtonPressed), for: .touchUpInside)
        return button
    }()
    private var actionButtonConfig = ButtonActionConfiguration()
    
    private let tableView = UITableView()
    
    private final let locationInputViewHeight: CGFloat = UIScreen.main.bounds.height * 0.3
    private final let rideActionViewHeight: CGFloat = UIScreen.main.bounds.height * 0.4
    
    private var user: User? {
        didSet {
            locationInputView.user = user
            guard let accountType = user?.accountType else { return }
            switch accountType {
            case .passenger:
                fetchDrivers()
                configureLocationInputActivationView()
            case .driver:
                observeTrips()
            }
        }
    }
    
    private var trip: Trip? {
        didSet {
            guard let trip = trip else { return }
            goToPickupController(trip: trip)
        }
    }
    
    private let service = Service()
    
    private var searchResults = [MKPlacemark]()
    
    private var routes: MKRoute?
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkIfUserIsLoggedIn()
        enableLocationServices()
        //signOut()
    }
    
    //MARK: - Selectors
    
    @objc private func actionButtonPressed() {
        switch actionButtonConfig {
        case .showMenu:
            print("DEBUG: actionButtonConfig ")
        case .dismissActionView:
            removeAnnotationsAndOverlays()
            mapView.showAnnotations(mapView.annotations, animated: true)
            UIView.animate(withDuration: 0.3) {
                self.locationInputActivationView.alpha = 1
                self.configureActionButton(config: self.actionButtonConfig)
            } completion: { _ in
                self.animateRideActionView(shouldShow: false)
            }
            
        }
    }
    
    //MARK: - API
    
    private func fetchDrivers() {
        guard let location = locationManager?.location else { return }
        Service.shared.fetchDrivers(location: location) { driver in
            guard let coordinate = driver.location?.coordinate else { return }
            let annotation = DriverAnnotation(uid: driver.uid, coordinate: coordinate)
            
            //check visiable annotation
            var driverIsVisible: Bool {
                return self.mapView.annotations.contains { annotation in
                    guard let driverAnnotaton = annotation as? DriverAnnotation else { return false}
                    //move annotetion if it already exist on mapView
                    if driverAnnotaton.uid == driver.uid {
                        driverAnnotaton.updateAnnotationPosition(withCoordinate: coordinate)
                        return true
                    }
                    return false
                }
            }
            
            //or add annotation on MapView
            if !driverIsVisible {
                self.mapView.addAnnotation(annotation)
            }
        }
    }
    
    private func observeTrips() {
        Service.shared.observeTrips { trip in
            self.trip = trip
        }
    }
    
    private func fetchCurrentUserData() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Service.shared.fetchUserData(uid: uid) { user in
            self.user = user
        }
    }
    
    private func checkIfUserIsLoggedIn() {
        if let uid = Auth.auth().currentUser?.uid {
            print("DEBUG: user id is \(uid)")
            configure()
        } else {
            DispatchQueue.main.async {
                self.goToLoginController()
                print("DEBUG: user is not logged on")
            }
            
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
    
//MARK: - Helper function
    
    func configure() {
        configureUI()
        fetchCurrentUserData()
    }
    
    private func goToLoginController() {
        let loginController = LoginController()
        loginController.modalPresentationStyle = .overFullScreen
        let navigationController = UINavigationController(rootViewController: loginController)
        present(navigationController, animated: true)
    }
    
    private func goToPickupController(trip: Trip) {
        let pickupController = PickupController(trip: trip)
        pickupController.delegate = self
        navigationController?.pushViewController(pickupController, animated: true)
        present(pickupController, animated: true)
    }
    
    private func configureUI() {
        configureMapView()
        
        view.addSubview(actionButton)
        actionButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor,
                            paddingTop: 16, paddingLeft: 20,
                            width: 30, height: 30)
        
        print(UIScreen.main.bounds.height)
        
        configureTableView()
        configureRideActionView()
    }
    
    //MARK: - Helper function Configure SubViews
    
    private func configureLocationInputActivationView() {
        view.addSubview(locationInputActivationView)
        locationInputActivationView.delegate = self
        locationInputActivationView.centerX(inView: view)
        locationInputActivationView.anchor(top: actionButton.bottomAnchor, paddingTop: 32,
                                           width: view.frame.width - 64, height: 50)
        
        locationInputActivationView.alpha = 0
        UIView.animate(withDuration: 2) {
            self.locationInputActivationView.alpha = 1
        }
    }
    
    private func configureMapView() {
        view.addSubview(mapView)
        mapView.frame = view.frame
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
    }
    
    private func configureLocationInputView() {
        
        view.addSubview(locationInputView)
        locationInputView.delegate = self
        locationInputView.anchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor, height: locationInputViewHeight)
        locationInputView.alpha = 0
        UIView.animate(withDuration: 0.5) {
            self.locationInputView.alpha = 1
        } completion: { _ in
            UIView.animate(withDuration: 0.2) {
                self.tableView.frame.origin.y = self.locationInputViewHeight
            }
            
        }
        
    }
    
    private func configureRideActionView() {
        view.addSubview(rideActionView)
        rideActionView.delegate = self
        rideActionView.frame = CGRect(x: 0,
                                      y: view.frame.height,
                                      width: view.frame.width,
                                      height: rideActionViewHeight)
        
    }
    
    private func configureTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(LocationCell.self, forCellReuseIdentifier: LocationCell.identifier)
        tableView.rowHeight = 60
        tableView.tableFooterView = UIView()
        let height = view.frame.height - locationInputViewHeight
        tableView.frame = CGRect(x: 0,
                                 y: view.frame.height,
                                 width: view.frame.width,
                                 height: height)
        view.addSubview(tableView)
        
    }
    
    private func configureActionButton(config: ButtonActionConfiguration) {
        switch config {
        case .showMenu :
            self.actionButtonConfig = .dismissActionView
            self.actionButton.setBackgroundImage(UIImage(systemName: "arrow.backward"), for: .normal)
        case .dismissActionView :
            self.actionButtonConfig = .showMenu
            self.actionButton.setBackgroundImage(UIImage(systemName: "list.bullet"), for: .normal)
        }
    }
    
    //MARK: - Helper function Animate
    
    func dismissInputLocationView(completion: ((Bool) -> Void)? = nil) {
        UIView.animate(withDuration: 0.2) {
            self.tableView.frame.origin.y = self.view.frame.height
        } completion: { _ in
            UIView.animate(withDuration: 0.3, animations: {
                self.locationInputView.alpha = 0
            }, completion: completion)
        }
    }
    
    func animateRideActionView(shouldShow: Bool) {
        let yOrigin = shouldShow ? self.view.frame.height - self.rideActionViewHeight : self.view.frame.height
        UIView.animate(withDuration: 0.3) {
            self.rideActionView.frame.origin.y = yOrigin
        }
    }
    
}

//MARK: - MapView Helper Functions

private extension HomeController {
    
    func zoomOnAnnotations() {
        let annotations = mapView.annotations.filter({ !$0.isKind(of: DriverAnnotation.self) })
        mapView.zoomToFit(annotations: annotations)
    }
    
    func removeAnnotationsAndOverlays() {
        mapView.annotations.forEach { annotation in
            if let annotation = annotation as? MKPointAnnotation {
                mapView.removeAnnotation(annotation)
            }
        }
        mapView.overlays.forEach { overlay in
            mapView.removeOverlay(overlay)
        }
    }
    
    func generatePolyLine(forDestination destination: MKMapItem) {
        
        let request = MKDirections.Request()
        request.source = MKMapItem.forCurrentLocation()
        request.destination = destination
        request.transportType = .automobile
        
        let directionRequest = MKDirections(request: request)
        directionRequest.calculate { responce, error in
            guard let responce = responce else { return }
            self.routes = responce.routes.first
            guard let polyline = self.routes?.polyline else { return }
            self.mapView.addOverlay(polyline)
        }
    }
    
    func searchBy(naturalLanguageQuery: String, completion: @escaping([MKPlacemark]) -> Void) {
        var results = [MKPlacemark]()
        
        //configure localSearch request
        let request = MKLocalSearch.Request()
        request.region = mapView.region
        request.naturalLanguageQuery = naturalLanguageQuery
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            guard let response = response else { return }
            response.mapItems.forEach { mapItem in
                results.append(mapItem.placemark)
            }
            completion(results)
        }
    }
    
}

//MARK: - LocationInputViewDelegate

extension HomeController: LocationInputActivationViewDelegate {
    
    func presentLocationInputView(_ locationInputActivationView: LocationInputActivationView) {
        configureLocationInputView()
        self.locationInputActivationView.alpha = 0
    }
    
}

extension HomeController: LocationInputViewDelegate {
    
    func executeSearch(query: String) {
        searchBy(naturalLanguageQuery: query) { (results) in
            self.searchResults = results
            self.tableView.reloadData()
        }
    }
    
    func didComplete(_ locationInputView: LocationInputView) {
        dismissInputLocationView { _ in
            self.locationInputView.removeFromSuperview()
            UIView.animate(withDuration: 0.3) {
                self.locationInputActivationView.alpha = 1
            }
        }
    }
    
    
}

//MARK: - LocationServices

extension HomeController {
    
    func enableLocationServices() {
        switch locationManager?.authorizationStatus {
        case .notDetermined:
            print("DEBUG: Not determined..")
            locationManager?.requestWhenInUseAuthorization()
        case .restricted:
            print("DEBUG: Auth restricted..")
        case .denied:
            break
        case .authorizedAlways:
            print("DEBUG: Auth always..")
            locationManager?.startUpdatingLocation()
            locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        case .authorizedWhenInUse:
            print("DEBUG: Auth when in use..")
            locationManager?.requestAlwaysAuthorization()
        @unknown default:
            break
        }
    }
    
    
}

//MARK: - UITableViewDataSource/Delegate

extension HomeController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "test"
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 2 : searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: LocationCell.identifier, for: indexPath) as! LocationCell
        if indexPath.section == 1 {
            let placemark = searchResults[indexPath.row]
            cell.placemark = placemark
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedPlacemark = searchResults[indexPath.row]
        
        configureActionButton(config: actionButtonConfig)
        
        //add Poly line to mapView
        let destination = MKMapItem(placemark: selectedPlacemark)
        generatePolyLine(forDestination: destination)
        
        dismissInputLocationView { _ in
            let annotation = MKPointAnnotation()
            annotation.coordinate = selectedPlacemark.coordinate
            self.mapView.addAnnotation(annotation)
            self.mapView.selectAnnotation(annotation, animated: true)
            self.zoomOnAnnotations()
            self.animateRideActionView(shouldShow: true)
            self.rideActionView.destination = selectedPlacemark
        }
        
    }
    
    
}

//MARK: MKMapViewDelegate

extension HomeController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let route = self.routes {
            let polyline = route.polyline
            let lineRender = MKPolylineRenderer(polyline: polyline)
            lineRender.strokeColor = .mainBlueTint
            lineRender.lineWidth = 3
            return lineRender
        }
        return MKOverlayRenderer()
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? DriverAnnotation {
            let view = MKAnnotationView(annotation: annotation, reuseIdentifier: driverAnnotationIdentifier)
            view.image = UIImage(systemName: "arrowtriangle.right.circle.fill")
            return view
        }
        return nil
    }
}

//MARK: - RideActionViewDelegate

extension HomeController: RideActionViewDelegate {
    
    func didComplete(_ rideActionView: RideActionView) {
        guard let pickupCoordinate = locationManager?.location?.coordinate,
        let destinationCoordinate = rideActionView.destination?.coordinate else { return }
        Service.shared.uploadTrip(pickupCoordinate, destinationCoordinate: destinationCoordinate) { error, reference in
            if let error = error {
                print("DEBUG: Failed to upload trip with error: \(error.localizedDescription)")
                return
            }
            print("DEBUG: Did upload trip successfully")
        }
    }
    
}

//MARK: PickupController Delegate

extension HomeController: PickupControllerDelegate {
    
    func didAcceptTrip(_ pickupController: PickupController) {
        self.trip?.state = .accepted
        pickupController.dismiss(animated: true)
    }
    
}
