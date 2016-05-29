//
//  ViewController.swift
//  VirtualTourist
//
//  Created by Reagan Wood on 5/28/16.
//  Copyright © 2016 RW Software. All rights reserved.
//

import UIKit
import MapKit

class TravelLocationsViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    var pressedDown: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        
        let latitude: Double = Double(NSUserDefaults.standardUserDefaults().floatForKey("mapLatitude"))
        let longitude: Double = Double(NSUserDefaults.standardUserDefaults().floatForKey("mapLongitude"))
        let latitudeSpan = Double(NSUserDefaults.standardUserDefaults().floatForKey("latitudeDelta"))
        let longitudeSpan = Double(NSUserDefaults.standardUserDefaults().floatForKey("longitudeDelta"))
        let span = MKCoordinateSpan(latitudeDelta: latitudeSpan, longitudeDelta: longitudeSpan)
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), span: span)
        mapView.setRegion(region, animated: true)
        
        print(mapView.region.span)
        longPressGestureActivated()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func getPinLocation(press: UILongPressGestureRecognizer) {
        
        if (pressedDown == false){ // makes sure multiple pins don't get added to the map
            pressedDown = true
            let point: CGPoint = press.locationInView(mapView)
            let location = mapView.convertPoint(point, toCoordinateFromView: mapView)
            addLocationToMap(location)
        } else if (press.state == .Ended) { // makes multiple pins don't get added to the map
            pressedDown = false
        }
        
        
    }

    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
       let Cl2D = mapView.region
        let latitudeFloat = Float (Cl2D.center.latitude)
        let longitudeFloat = Float(Cl2D.center.longitude)
        let coordinateSpan = mapView.region.span
        let floatLatitudeSpan = Float(coordinateSpan.latitudeDelta)
        let floatLongitudeSpan = Float(coordinateSpan.longitudeDelta)
        NSUserDefaults.standardUserDefaults().setFloat(latitudeFloat, forKey: "mapLatitude")
        NSUserDefaults.standardUserDefaults().setFloat(longitudeFloat, forKey: "mapLongitude")
        NSUserDefaults.standardUserDefaults().setFloat(floatLatitudeSpan, forKey: "latitudeDelta")
        NSUserDefaults.standardUserDefaults().setFloat(floatLongitudeSpan, forKey: "longitudeDelta")
    }
    func addLocationToMap(location: CLLocationCoordinate2D){
        // TODO: check to see if the pin alread contains a location
        print(mapView.region.center)
        // Add the annotation to the map
        let annotation = MKPointAnnotation()
        annotation.coordinate = location
        mapView.addAnnotation(annotation)
    }
    
    
    func longPressGestureActivated () {
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(TravelLocationsViewController.getPinLocation(_:)))
        longPressGesture.minimumPressDuration = 1
        mapView.addGestureRecognizer(longPressGesture)
    }
    
    //  sets pin type
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = UIColor.redColor()
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    } // end function
    
}

