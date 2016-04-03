//
//  DetailViewController.swift
//  test
//
//  Created by Stephen McIntosh on 4/03/2016.
//  Copyright © 2016 Stephen McIntosh. All rights reserved.
//

import MapKit
import UIKit

class DetailViewController: UIViewController, UIGestureRecognizerDelegate {
    
    // MARK: Properties
    var justParkSearchLocation: CLLocation?
    var justParkResult: [String : AnyObject]?
    var justParkResultLocation: CLLocation?
    
    var coordinate: CLLocationCoordinate2D = kCLLocationCoordinate2DInvalid
    var locationRequest: LocationOperation?
    var queue: OperationQueue?
    
    @IBOutlet weak var mapView: MKMapView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let justParkResult = justParkResult,
                let _ = justParkSearchLocation,
                let justParkResultLocationLat = justParkResult["coords"]!["lat"]! as? CLLocationDegrees,
                let justParkResultLocationLng = justParkResult["coords"]!["lng"]! as? CLLocationDegrees else { return }
        

        coordinate = CLLocationCoordinate2DMake(justParkResultLocationLat, justParkResultLocationLng)
        
        guard CLLocationCoordinate2DIsValid(coordinate) else { return }
        
        justParkResultLocation = CLLocation.init(latitude: justParkResultLocationLat, longitude: justParkResultLocationLng)
        if (justParkResultLocation != nil) {
            let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            
            mapView.showsCompass = false
            mapView.region = MKCoordinateRegion(center: coordinate, span: span)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            mapView.addAnnotation(annotation)
            
            let locationOperation = LocationOperation(accuracy: kCLLocationAccuracyKilometer) { location in
                let distance = location.distanceFromLocation(self.justParkResultLocation!)
                self.locationRequest = nil
            }
            
            queue?.addOperation(locationOperation)
            locationRequest = locationOperation
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated) //
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        // If the LocationOperation is still going on, then cancel it.
        locationRequest?.cancel()
    }
}

extension DetailViewController: MKMapViewDelegate {
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        guard let justParkResult = justParkResult else { return nil }
        
        var view = mapView.dequeueReusableAnnotationViewWithIdentifier("pin") as? MKPinAnnotationView
        
        view = view ?? MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
        
        guard let pin = view else { return nil }
        
        guard let theJustParkResult = justParkResult["feedback"]?["rating"] as? Double else { return pin }
        
        switch theJustParkResult {
        case 0.0..<3.0: pin.pinTintColor = UIColor.grayColor()
        case 3.0..<4.0: pin.pinTintColor = UIColor.blueColor()
        case 4.0..<5.0: pin.pinTintColor = UIColor.orangeColor()
        default:    pin.pinTintColor = UIColor.redColor()
        }
        
        pin.enabled = false
        
        return pin
    }
}