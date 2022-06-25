//
//  PickupController.swift
//  Uber
//
//  Created by Apple on 24.06.2022.
//

import UIKit
import MapKit

protocol PickupControllerDelegate: AnyObject {
    func didAcceptTrip(_ pickupController: PickupController)
}

class PickupController: UIViewController {
    
    //MARK: - Properties
    
    weak var delegate: PickupControllerDelegate?
    
    private let mapView = MKMapView()
    
    var trip: Trip
    
    private let cancelButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(systemName: "xmark.circle"), for: .normal)
        button.addTarget(self, action: #selector(handleDismissal), for: .touchUpInside)
        button.tintColor = .white
        return button
    }()
    
    private let pickupLabel: UILabel = {
       let label = UILabel()
        label.text = "Would you like to pickup this passenger?"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .white
        return label
    }()
    
    private let acceptTripButton: UIButton = {
        let button = UIButton()
        button.setTitle("ACCEPT TRIP", for: .normal)
        button.addTarget(self, action: #selector(handleAcceptTrip), for: .touchUpInside)
        button.backgroundColor = .white
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        button.setTitleColor(.black, for: .normal)
        return button
    }()
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    //MARK: - Lifecycle
    
    init(trip: Trip) {
        self.trip = trip
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureMapView()
    }
    
    //MARK: - Helper Function
    
    private func configureMapView() {
        let region = MKCoordinateRegion(center: trip.pickupCoordinates, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(region, animated: true)
        
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = trip.pickupCoordinates
        mapView.addAnnotation(annotation)
        mapView.selectAnnotation(annotation, animated: true)
    }
    
    private func configureUI() {
        view.backgroundColor = .backGroundColor
        setupCancelButton()
        setupMapView()
        setupPickupLabel()
        setupAcceptTripButton()
    }
    
    private func setupCancelButton() {
        view.addSubview(cancelButton)
        cancelButton.anchor(top: view?.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor,
                            paddingTop: 16, paddingLeft: 16)
    }
    
    private func setupMapView() {
        view.addSubview(mapView)
        mapView.setDimensions(height: 240)
        mapView.layer.cornerRadius = 240 / 2
        mapView.centerX(inView: view)
        mapView.centerY(inView: view, constant: -80)
    }
    
    private func setupPickupLabel() {
        view.addSubview(pickupLabel)
        pickupLabel.centerX(inView: view)
        pickupLabel.anchor(top: mapView.bottomAnchor, paddingTop: 16)
    }
    
    private func setupAcceptTripButton() {
        view.addSubview(acceptTripButton)
        acceptTripButton.anchor(top: pickupLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor,
                                paddingTop: 16, paddingLeft: 32, paddinRight: 32, height: 40)
    }
 
    //MARK: - Selectors
    
    @objc private func handleDismissal() {
        dismiss(animated: true)
    }
    
    @objc private func handleAcceptTrip() {
        Service.shared.acceptTrip(trip: trip) { error, reference in
            self.delegate?.didAcceptTrip(self) 
        }
    }
    
    //MARK: - API
}
