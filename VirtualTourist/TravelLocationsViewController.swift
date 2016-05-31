//
//  ViewController.swift
//  VirtualTourist
//
//  Created by Reagan Wood on 5/28/16.
//  Copyright © 2016 RW Software. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class TravelLocationsViewController: UIViewController, MKMapViewDelegate, NSFetchedResultsControllerDelegate{

    @IBOutlet weak var mapView: MKMapView!
    var pins = [NSManagedObject]()
    
    // variable used to ensure only one pin is dropped on LongPress
    var pressedDown: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        // sets zoom location before load
        let latitude: Double = Double(NSUserDefaults.standardUserDefaults().floatForKey("mapLatitude"))
        let longitude: Double = Double(NSUserDefaults.standardUserDefaults().floatForKey("mapLongitude"))
        let latitudeSpan = Double(NSUserDefaults.standardUserDefaults().floatForKey("latitudeDelta"))
        let longitudeSpan = Double(NSUserDefaults.standardUserDefaults().floatForKey("longitudeDelta"))
        let span = MKCoordinateSpan(latitudeDelta: latitudeSpan, longitudeDelta: longitudeSpan)
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), span: span)
        mapView.setRegion(region, animated: true)
        
        // set longPressGesture to the mapView
        longPressGestureActivated()
        preLoadMap()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func preLoadMap() {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let stackContext = appDelegate.stack.context
        let fetchedRequest = NSFetchRequest(entityName: "LocationPin")
        
        do {
            let results = try stackContext.executeFetchRequest(fetchedRequest)
            pins = results as! [NSManagedObject]
            addPinsToMap()
        } catch {
            
        }
    }
    
    func addPinsToMap() {
        if (pins.count > 0) {
            
            for (var i = 0; i < pins.count; i += 1){
                let point = MKPointAnnotation()
                let certainPin = pins[i] as! LocationPin
                let latitudeDouble = certainPin.latitude as! Double
                let longitudeDouble = certainPin.longitude as! Double
                let coordinate = CLLocationCoordinate2D(latitude: latitudeDouble, longitude: longitudeDouble)
                point.coordinate = coordinate
                mapView.addAnnotation(point)
            }
        }
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

    // persists the location of the zoom
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
        // Add the annotation to the map
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let stackContext = appDelegate.stack.context
        let entity = NSEntityDescription.entityForName("LocationPin", inManagedObjectContext: stackContext)
        let pin = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: stackContext)
        pin.setValue(location.latitude, forKey: "latitude")
        pin.setValue(location.longitude, forKey: "longitude")
        
        do {
            try stackContext.save()
            //5
            pins.append(pin) // if there is an error here, pin won't be posted to the map.
            let annotation = MKPointAnnotation()
            annotation.coordinate = location
            mapView.addAnnotation(annotation)
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }

    }
    
    // sets the long press to the mapView
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

