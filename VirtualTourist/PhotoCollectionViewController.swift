//
//  PhotoCollectionViewController.swift
//  VirtualTourist
//
//  Created by Reagan Wood on 5/29/16.
//  Copyright © 2016 RW Software. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreData

class PhotoCollectionViewController: UIViewController {
    
    // global variables
    var pin: MKAnnotation?
    var photoArray = [LocationImage]()
    var locationOfPin: LocationPin!
    var stack: CoreDataStack!
    var indexes = [NSIndexPath]()
    var photoURLs = [String]()
    
    // Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var flickrPhotoCollectionView: UICollectionView!
    
    @IBOutlet weak var newCollectionButton: UIButton!
    
    var fetchedResultsController : NSFetchedResultsController? {
        didSet{
            fetchedResultsController?.delegate = self
            completeSearch()
            performUIUpdatesOnMain(self.flickrPhotoCollectionView.reloadData())
            
        }
    }
    
    init (fetchedResultsController fc : NSFetchedResultsController) {
        fetchedResultsController = fc
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let pinLocation = pin{
            
            mapView.userInteractionEnabled = false
            
            let center = CLLocationCoordinate2D(latitude: pinLocation.coordinate.latitude, longitude: pinLocation.coordinate.longitude)
            let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            let region = MKCoordinateRegion(center: center, span: span)

            mapView.setRegion(region, animated: true)
        } else {
            print("error retrieving map information")
        }// end if
        
        // initiate the photo collection view
        flickrPhotoCollectionView.allowsMultipleSelection = true
        self.flickrPhotoCollectionView.hidden = false
        
        if (fetchedResultsController!.fetchedObjects?.count == 0) {
            
            if let mapPin = locationOfPin {
                newCollectionButton.enabled = false
                
                
            }
        }
    } // end function
    
    // request more Photos for this Pin from Flickr and store in CORE Data
    func getPhotos(pin: LocationPin, completionHandler: (success: Bool, count: Int, errorString: String?) -> Void) {
        
        guard let latitude = pin.latitude as? Double, longitude = pin.longitude as? Double else {
            completionHandler(success: false, count: 0, errorString: "Could not get photos")
            return
        }
        
        FlickrClient.sharedInstance().retrievePhotosFromFlickr(latitude, longitude: longitude) { (success, photoURLs, error) in
            
            if success == false {
                print("error")
                completionHandler(success: false, count: 0, errorString: "There was an error retrieving results")
                return
            }
            
            if photoURLs.count > 0 {
                for url in photoURLs {
                    let newPhoto = LocationImage (
                }
            }
        }
        
        
        //print("initiate Flickr request")
        FlickrClient.sharedInstance().getLocationPhotos(latitude, longitude: longitude) { (success, error, results) in
            
            if success == false {
                completionHandler(success: false, count: 0, errorString: "Photos could not be retrieved")
                return
            }
            
            if let photos = results {
                
                print("creating new Photos in CORE Data")
                for url in photos {
                    let photo = Photo(url: url, context: self.fetchedResultsController!.managedObjectContext)
                    photo.pin = self.selectedPin
                }
                
                performUIUpdatesOnMain {
                    // needed because 'insert' event never fires for the frc
                    self.completeSearch()
                    self.photosCollectionView.reloadData()
                }
                
                print("new cell count provided by Flickr request for photos: \(urls.count)")
                completionHandler(success: true, count: urls.count, errorMessage: nil)
                
            } else {
                completionHandler(success: false, count: 0, errorMessage: "Error getting photo urls")
            }
        }
    }
} // end class

extension PhotoCollectionViewController {
    
    func completeSearch() {
        if let fetchedController = fetchedResultsController {
            do {
                try fetchedController.performFetch()
            } catch let exception as NSError {
                print("There was an error while performing fetch: \(exception)")
            }
        }
    }
} // end extension