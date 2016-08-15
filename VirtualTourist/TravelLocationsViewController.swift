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
    var locationPin: NSManagedObject?
    
    // variable used to ensure only one pin is dropped on LongPress
    var pressedDown: Bool = false
    
    var fetchedResultsController : NSFetchedResultsController? {
        didSet {
            fetchedResultsController?.delegate = self
              completeSearch()
//            mapDataReload()
        } // end didSet
    } // end fetchedResultsController declaration
    
    init(fetchedResultsController fc : NSFetchedResultsController) {
        fetchedResultsController = fc
        super.init(nibName: nil, bundle: nil)
    }
    
    // code for objective C
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        // sets zoom location before load
        let latitude: Double = Double(NSUserDefaults.standardUserDefaults().stringForKey("mapLatitude")!)!
        let longitude: Double = Double(NSUserDefaults.standardUserDefaults().stringForKey("mapLongitude")!)!
        let latitudeSpan = Double(NSUserDefaults.standardUserDefaults().stringForKey("latitudeDelta")!)
        let longitudeSpan = Double(NSUserDefaults.standardUserDefaults().stringForKey("longitudeDelta")!)
        let span = MKCoordinateSpan(latitudeDelta: latitudeSpan!, longitudeDelta: longitudeSpan!)
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
        
        // Create a fetchrequest
        let fr = NSFetchRequest(entityName: "LocationPin")
        fr.sortDescriptors = []
        
        // Create the FetchedResultsController
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fr,
                                                              managedObjectContext: stackContext, sectionNameKeyPath: nil, cacheName: nil)
        
        do {
            let results = try stackContext.executeFetchRequest(fetchedRequest)
            pins = results as! [NSManagedObject]
            addPinsToMap()
        } catch {
            
        }
    }
    
    func addPinsToMap() {
        if (pins.count > 0) {
            for obj in pins{
                let point = MKPointAnnotation()
                let certainPin = obj as! LocationPin
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
        let latitudeString = String(Cl2D.center.latitude)
        let longitudeString = String(Cl2D.center.longitude)
        let coordinateSpan = mapView.region.span
        let floatLatitudeSpanString = String(coordinateSpan.latitudeDelta)
        let floatLongitudeSpanString = String(coordinateSpan.longitudeDelta)
        print(longitudeString)
        print(latitudeString)
        //NSUserDefaults.standardUserDefaults().setFloat(latitudeFloat, forKey: "mapLatitude")
        NSUserDefaults.standardUserDefaults().setObject(latitudeString, forKey: "mapLatitude")
        //NSUserDefaults.standardUserDefaults().setFloat(longitudeFloat, forKey: "mapLongitude")
        NSUserDefaults.standardUserDefaults().setObject(longitudeString, forKey: "mapLongitude")
        //NSUserDefaults.standardUserDefaults().setFloat(floatLatitudeSpan, forKey: "latitudeDelta")
        NSUserDefaults.standardUserDefaults().setObject(floatLatitudeSpanString, forKey: "latitudeDelta")
        //NSUserDefaults.standardUserDefaults().setFloat(floatLongitudeSpan, forKey: "longitudeDelta")
        NSUserDefaults.standardUserDefaults().setObject(floatLongitudeSpanString, forKey: "longitudeDelta")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    func addLocationToMap(location: CLLocationCoordinate2D){
        // TODO: check to see if the pin alread contains a location
        // Add the annotation to the map
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let stackContext = appDelegate.stack.context
        let entity = NSEntityDescription.entityForName("LocationPin", inManagedObjectContext: stackContext)
        //let pin = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: stackContext)
        let pin1 = LocationPin(latitude: location.latitude, longitude: location.longitude, context: self.fetchedResultsController!.managedObjectContext)/////
        completeSearch()
        pin1.setValue(location.latitude, forKey: "latitude")
        pin1.setValue(location.longitude, forKey: "longitude")
        
        do {
            try stackContext.save()
            //5
            pins.append(pin1) // if there is an error here, pin won't be posted to the map.
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
            pinView!.canShowCallout = false
            pinView!.pinTintColor = UIColor.redColor()
            //pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    } // end function
    
    // segue to the PhotoAlbumViewController
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        
        // create the ViewController
        let photoVC = storyboard!.instantiateViewControllerWithIdentifier("PhotoAlbumCollectionViewController") as! PhotoCollectionViewController
        
        
        
        
        let clickedPinLat = view.annotation?.coordinate.latitude
        let clickedPinLong = view.annotation?.coordinate.longitude
        
        if let pins = fetchedResultsController!.fetchedObjects as? [LocationPin] {
            let PinsAfterFilter = pins.filter({ (p: LocationPin) -> Bool in
                return p.latitude == clickedPinLat && p.longitude == clickedPinLong
            })
            if let thisPin = PinsAfterFilter.first {
                locationPin = thisPin
                let fetch = NSFetchRequest(entityName: "LocationImage")
                fetch.sortDescriptors = []
                let predicate = NSPredicate(format: "locationPin = %@", locationPin!)
                fetch.predicate = predicate
                
               let fc = NSFetchedResultsController(fetchRequest: fetch, managedObjectContext: fetchedResultsController!.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
                
                print(fc.fetchedObjects?.count)
                photoVC.locationOfPin = thisPin
                photoVC.pin = view.annotation
                photoVC.fetchedResultsController = fc
                // once you have this, run the handler completionHandler!
                    
                    //2. Present the view controller
                    self.navigationController?.pushViewController(photoVC, animated: true)
                    mapView.deselectAnnotation(view.annotation, animated: false)
                
            }
        }// end if
        
    } // end function
}

extension TravelLocationsViewController {
    
    func completeSearch(){
        if let fc = fetchedResultsController{
            do{
                try fc.performFetch()
            }catch let e as NSError{
                print("Error: could not performa a fetch")
            }
        }
    }
}

