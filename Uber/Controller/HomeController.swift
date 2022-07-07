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

private enum AnnotationType: String {
    case pickup
    case destination
}

protocol HomeControllerDelegate: AnyObject {
    func handleMenuToggle(_ homeController: HomeController)
}

class HomeController: UIViewController {
    
    //MARK: - Properties
    
    //MARK: Constant
    
    private final let locationInputViewHeight: CGFloat = UIScreen.main.bounds.height * 0.3
    private final let rideActionViewHeight: CGFloat = UIScreen.main.bounds.height * 0.4
    
    //MARK: Service
    
    private let locationManager = LocationHandler.shared.locationManager
    
    private var searchResults = [MKPlacemark]()
    private var savedLocations = [MKPlacemark]()
    private var routes: MKRoute?
    
    weak var delegate: HomeControllerDelegate?
    
    //MARK: UI
    
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
    
    //MARK: Model
    
    var user: User? {
        didSet {
            checkAccountTypeUser()
        }
    }
    
    private var trip: Trip? {
        didSet {
            guard let user = user else { return }
            switch user.accountType {
            case .passenger:
                print("DEBUG: Your trip load..")
            case .driver:
                guard let trip = trip else { return }
                goToPickupController(trip: trip)
            }
        }
    }
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        enableLocationServices()
    }
    
    //MARK: - Selectors
    
    @objc private func actionButtonPressed() {
        switch actionButtonConfig {
        case .showMenu:
            delegate?.handleMenuToggle(self)
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
    
    //MARK: Passenger API
    
    private func startTrip() {
        guard let trip = trip else { return }
        DriverService.shared.updateTripState(trip: trip, state: .inProgress) { error, reference in
            self.rideActionView.config = .tripInProgress
            self.removeAnnotationsAndOverlays()
            self.mapView.addAndSelectAnnotation(forCoordinate: trip.destinationCoordinates)
            let placemark = MKPlacemark(coordinate: trip.destinationCoordinates)
            let mapItem = MKMapItem(placemark: placemark)
            self.generatePolyLine(forDestination: mapItem)
            self.setCustomRegion(withType: .destination, coordinates: trip.destinationCoordinates)
            self.mapView.zoomToFit(annotations: self.mapView.annotations)
        }
    }
    
    private func observeCurrentTrip() {
        PassengerService.shared.observeCurrentTrip { trip in
            self.trip = trip
            guard let driverUid = trip.drivarUid else { return }
            switch trip.state {
            case .requested:
                break
            case .accepted:
                self.shouldPresentLoadingView(false)
                self.removeAnnotationsAndOverlays()
                self.zoomForActiveTrip(withDriverUid: driverUid)
                Service.shared.fetchUserData(uid: driverUid) { driver in
                    self.animateRideActionView(shouldShow: true, user: driver, withConfig: .tripAccepted)
                }
            case .driverArrived:
                self.rideActionView.config = .driverArrived
            case .inProgress:
                self.rideActionView.config = .tripInProgress
            case .arrivedAtDestination:
                self.rideActionView.config = .endTrip
            case .completed:
                PassengerService.shared.deleteTrip { error, reference in
                    if let error = error {
                        print("DEBUG: Failed to delete trip with error: \(error.localizedDescription)")
                    }
                    self.animateRideActionView(shouldShow: false)
                    self.centerMapOnuserLocation()
                    self.configureActionButton(config: .dismissActionView)
                    self.presentAlertControlle(withTitle: "Trip completed", withMessage: "We hope you enjoyed your trip", handler:  { _ in
                        UIView.animate(withDuration: 0.3) {
                            self.locationInputActivationView.alpha = 1
                        }
                    })
                    
                }
            }
        }
    }
    
    private func fetchDrivers() {
        guard let location = locationManager?.location else { return }
        PassengerService.shared.fetchDrivers(location: location) { driver in
            guard let coordinate = driver.location?.coordinate else { return }
            let annotation = DriverAnnotation(uid: driver.uid, coordinate: coordinate)
            
            //check visiable annotation
            var driverIsVisible: Bool {
                return self.mapView.annotations.contains { annotation in
                    guard let driverAnnotaton = annotation as? DriverAnnotation else { return false}
                    //move annotetion if it already exist on mapView
                    if driverAnnotaton.uid == driver.uid {
                        driverAnnotaton.updateAnnotationPosition(withCoordinate: coordinate)
                        self.zoomForActiveTrip(withDriverUid: driver.uid)
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
    
    //MARK: Driver API
    
    private func observeTrips() {
        DriverService.shared.observeTrips { trip in
            self.trip = trip
        }
    }
    
    private func observedCancelledTrip(trip: Trip) {
        DriverService.shared.observeTripCancelled(trip: trip) {
            self.removeAnnotationsAndOverlays()
            self.animateRideActionView(shouldShow: false)
            self.centerMapOnuserLocation()
            self.presentAlertControlle(withTitle: "Oops!", withMessage: "The passenger has decided to cancelled this ride.")
        }
    }
    
//MARK: - Navigation function
    
    private func goToPickupController(trip: Trip) {
        let pickupController = PickupController(trip: trip)
        pickupController.delegate = self
        navigationController?.pushViewController(pickupController, animated: true)
        present(pickupController, animated: true)
    }
    
//MARK: - Helper function
    
    private func configure() {
        configureUI()
        //checkAccountTypeUser()
    }
    
    private func checkAccountTypeUser() {
        guard let user = user else { return }
        switch user.accountType {
        case .passenger:
            fetchDrivers()
            configureLocationInputActivationView()
            observeCurrentTrip()
            configureSavedUserLocations()
        case .driver:
            observeTrips()
        }
    }
    
    private func configureUI() {
        configureMapView()
        
        view.addSubview(actionButton)
        actionButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor,
                            paddingTop: 16, paddingLeft: 20,
                            width: 30, height: 30)
        
        configureTableView()
        configureRideActionView()
    }
    
    func configureSavedUserLocations() {
        guard let user = user else { return }
        if let homeLoaction = user.homeLocation {
            geocodeAddressString(address: homeLoaction)
        }
        
        if let workLocation = user.workLocation {
            geocodeAddressString(address: workLocation)
            
        }
    }
    
    func geocodeAddressString(address: String) {
        savedLocations.removeAll()
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { placemarks, error in
            guard let clPlacemark = placemarks?.first else { return }
            let placemark = MKPlacemark(placemark: clPlacemark)
            self.savedLocations.append(placemark)
            self.tableView.reloadData()
            print("DEBUG: \(placemarks)")
        }
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
        UIView.animate(withDuration: 0.3) {
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
    
    private func dismissInputLocationView(completion: ((Bool) -> Void)? = nil) {
        UIView.animate(withDuration: 0.2) {
            self.tableView.frame.origin.y = self.view.frame.height
        } completion: { _ in
            UIView.animate(withDuration: 0.3, animations: {
                self.locationInputView.alpha = 0
            }, completion: completion)
        }
    }
    
    private func animateRideActionView(shouldShow: Bool,
                               destination: MKPlacemark? = nil,
                               user: User? = nil,
                               withConfig config: RideActionViewConfiguration? = nil) {
        
        rideActionView.user = user
        rideActionView.destination = destination
        if let config = config {
            rideActionView.config = config
        }
        
        
        let yOrigin = shouldShow ? self.view.frame.height - self.rideActionViewHeight : self.view.frame.height
        UIView.animate(withDuration: 0.3) {
            self.rideActionView.frame.origin.y = yOrigin
        }
    }
    
}

//MARK: - MapView Helper Functions

private extension HomeController {
    
    private func zoomForActiveTrip(withDriverUid driverUid: String) {
        var annotations = [MKAnnotation]()
        self.mapView.annotations.forEach { annotation in
            if let annotation = annotation as? DriverAnnotation {
                if annotation.uid == driverUid {
                    annotations.append(annotation)
                }
            }
            if let userAnnotation = annotation as? MKUserLocation {
                annotations.append(userAnnotation)
            }
        }
        self.mapView.zoomToFit(annotations: annotations)
    }
    
    private func setCustomRegion(withType type: AnnotationType, coordinates: CLLocationCoordinate2D) {
        let region = CLCircularRegion(center: coordinates, radius: 25, identifier: type.rawValue)
        locationManager?.startMonitoring(for: region)
    }
    
    private func centerMapOnuserLocation() {
        guard let coordinate = locationManager?.location?.coordinate else { return }
        let region = MKCoordinateRegion(center: coordinate,
                                        latitudinalMeters: 2000,
                                        longitudinalMeters: 2000)
        mapView.setRegion(region, animated: true)
    }
    
    private func zoomOnAnnotations() {
        let annotations = mapView.annotations.filter({ !$0.isKind(of: DriverAnnotation.self) })
        mapView.zoomToFit(annotations: annotations)
    }
    
    private func removeAnnotationsAndOverlays() {
        mapView.annotations.forEach { annotation in
            if let annotation = annotation as? MKPointAnnotation {
                mapView.removeAnnotation(annotation)
            }
        }
        mapView.overlays.forEach { overlay in
            mapView.removeOverlay(overlay)
        }
    }
    
    private func generatePolyLine(forDestination destination: MKMapItem) {
        
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
    
    private func searchBy(naturalLanguageQuery: String, completion: @escaping([MKPlacemark]) -> Void) {
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

//MARK: - LocationInputActivationViewDelegate

extension HomeController: LocationInputActivationViewDelegate {
    
    func presentLocationInputView(_ locationInputActivationView: LocationInputActivationView) {
        configureLocationInputView()
        self.locationInputActivationView.alpha = 0
    }
    
}

//MARK: - LocationInputViewDelegate

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

//MARK: - CLLocationManagerDelegate

extension HomeController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        switch region.identifier {
        case AnnotationType.pickup.rawValue:
            print("DEBUG: Did start monitoring pickup region \(region)")
        case AnnotationType.destination.rawValue:
            print("DEBUG: Did start monitoring destination region \(region)")
        default:
            return
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("DEBUG: Driver did enter passenger region..")
        guard let trip = trip else {  return }
        switch region.identifier {
        case AnnotationType.pickup.rawValue:
            DriverService.shared.updateTripState(trip: trip, state: .driverArrived) { error, reference in
                self.rideActionView.config = .pickupPassenger
            }
        case AnnotationType.destination.rawValue:
            DriverService.shared.updateTripState(trip: trip, state: .arrivedAtDestination) { error, reference in
                self.rideActionView.config = .endTrip
            }
        default:
            return
        }
    }
    
    func enableLocationServices() {
        locationManager?.delegate = self
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
        return section == 0 ? "Saved locations" : "Search Results"
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return savedLocations.isEmpty ? 1 : 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? savedLocations.count : searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: LocationCell.identifier, for: indexPath) as! LocationCell
        let placemark = indexPath.section == 0 ? savedLocations[indexPath.section] : searchResults[indexPath.row]
//        if indexPath.section == 1 {
//            let placemark = searchResults[indexPath.row]
//            cell.placemark = placemark
//        }
        cell.placemark = placemark
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedPlacemark = indexPath.section == 0 ? savedLocations[indexPath.row] : searchResults[indexPath.row]
        configureActionButton(config: actionButtonConfig)
        
        //add Poly line to mapView
        let destination = MKMapItem(placemark: selectedPlacemark)
        generatePolyLine(forDestination: destination)
        
        dismissInputLocationView { _ in
            self.mapView.addAndSelectAnnotation(forCoordinate: selectedPlacemark.coordinate)
            self.zoomOnAnnotations()
            self.animateRideActionView(shouldShow: true, destination: selectedPlacemark)
        }
        
    }
    
    
}

//MARK: MKMapViewDelegate

extension HomeController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        guard let user = user,
              user.accountType == .driver,
                let location = userLocation.location else { return }
        //Upload new current location to fireBase
        DriverService.shared.updateDriverLocation(loaction: location)
    }
    
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
    
    func pickupPassenger(_ rideActionView: RideActionView) {
        startTrip()
    }
    
    func uploadTrip(_ rideActionView: RideActionView) {
        guard let pickupCoordinate = locationManager?.location?.coordinate,
        let destinationCoordinate = rideActionView.destination?.coordinate else { return }
        shouldPresentLoadingView(true, message: "Finding your a ride..")
        PassengerService.shared.uploadTrip(pickupCoordinate, destinationCoordinate: destinationCoordinate) { error, reference in
            if let error = error {
                print("DEBUG: Failed to upload trip with error: \(error.localizedDescription)")
                return
            }
            UIView.animate(withDuration: 0.2) {
                self.rideActionView.frame.origin.y = self.view.frame.height
            } completion: { _ in
                print("DEBUG: Did upload trip successfully")
            }
        }
    }
    
    func cancelTrip(_ rideActionView: RideActionView) {
        PassengerService.shared.deleteTrip { error, referance in
            if let error = error {
                print("DEBUG: Error deleting trip with: \(error.localizedDescription)")
            }
            self.animateRideActionView(shouldShow: false)
            self.removeAnnotationsAndOverlays()
            self.centerMapOnuserLocation()
            self.configureActionButton(config: .dismissActionView)
            self.rideActionView.config = .requestRide
            
            UIView.animate(withDuration: 0.3) {
                self.locationInputActivationView.alpha = 1
            }

        }
    }
    
    func dropOffPassenger(_ rideActionView: RideActionView) {
        guard let trip = trip else { return }
        DriverService.shared.updateTripState(trip: trip, state: .completed) { error, reference in
            self.removeAnnotationsAndOverlays()
            self.centerMapOnuserLocation()
            self.animateRideActionView(shouldShow: false)
            
        }
    }
    
}

//MARK: PickupController Delegate

extension HomeController: PickupControllerDelegate {
    
    func didAcceptTrip(_ pickupController: PickupController) {
        let trip = pickupController.trip
        mapView.addAndSelectAnnotation(forCoordinate: trip.pickupCoordinates)
        setCustomRegion(withType: .pickup, coordinates: trip.pickupCoordinates)
        
        let placemark = MKPlacemark(coordinate: trip.pickupCoordinates)
        let mapItem = MKMapItem(placemark: placemark)
        generatePolyLine(forDestination: mapItem)
        
        observedCancelledTrip(trip: trip)
        
        mapView.zoomToFit(annotations: mapView.annotations)
        pickupController.dismiss(animated: true) {
            Service.shared.fetchUserData(uid: trip.passangerUid) { passenger in
                self.animateRideActionView(shouldShow: true, user: passenger, withConfig: .tripAccepted)
            }
        }
    }
    
}
