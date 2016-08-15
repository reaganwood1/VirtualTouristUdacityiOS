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

    var indexes = [NSIndexPath]()
    var photoURLs = [String]()
    var deleteNeededVariables = [NSIndexPath]()
    
    // Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var flickrPhotoCollectionView: UICollectionView!
    
    @IBOutlet weak var newCollectionButton: UIButton!
    
    var fetchedResultsController : NSFetchedResultsController? {
        didSet{
            fetchedResultsController?.delegate = self
            completeSearch()
            performUIUpdatesOnMain { 
                self.flickrPhotoCollectionView.reloadData()
            }
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
        
        flickrPhotoCollectionView.dataSource = self
        flickrPhotoCollectionView.delegate = self
        
        if let pinLocation = pin{
            
            mapView.userInteractionEnabled = false
            
            let center = CLLocationCoordinate2D(latitude: pinLocation.coordinate.latitude, longitude: pinLocation.coordinate.longitude)
            let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            let region = MKCoordinateRegion(center: center, span: span)

            mapView.setRegion(region, animated: true)
            mapView.addAnnotation(pinLocation)
        } else {
            print("error retrieving map information")
        }// end if
        
        // initiate the photo collection view
        flickrPhotoCollectionView.allowsMultipleSelection = true
        self.flickrPhotoCollectionView.hidden = false
        
        if (fetchedResultsController!.fetchedObjects?.count == 0) { // if count is 0, retrieve more photos
            
            if let mapPin = locationOfPin { // set the pin for retrieval location
                newCollectionButton.enabled = false
                getPhotos(mapPin, completionHandler: { (success, count, errorString) in
                    performUIUpdatesOnMain({ 
                        if success == false {
                            self.newCollectionButton.enabled = true
                            print("error in getPhotos")
                        } else {
                            do {
                                try self.fetchedResultsController!.managedObjectContext.save()
                                self.flickrPhotoCollectionView.reloadData()
                            }catch {
                                print("nothing was saved")
                            }
                        } // end else
                    }) // end UIUpdates
                    
                    if count == 0 {
                        self.flickrPhotoCollectionView.hidden = true
                    } else {
                        self.flickrPhotoCollectionView.hidden = false
                    }
                    
                    performUIUpdatesOnMain({
                        self.newCollectionButton.enabled = true
                    })
                }) // end get photos
            } // end if for mapPin
        } // end if for fetchedObject count
    } // end function
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func createNewCollectionButtonSelected(sender: AnyObject) {
        
        if newCollectionButton.titleLabel!.text == "New Collection" {
            if let locPin = locationOfPin {
                
                performUIUpdatesOnMain({
                    self.newCollectionButton.enabled = false
                })
                
                clearImages(locPin)
                
                getPhotos(locPin, completionHandler: { (success, count, errorString) in
                    
                    performUIUpdatesOnMain({ 
                        if success == false {
                            self.newCollectionButton.enabled = true
                            print("error")
                        } else {
                            do {
                                try self.fetchedResultsController!.managedObjectContext.save()
                                self.flickrPhotoCollectionView.reloadData()
                            } catch {
                                print("could not save")
                            } // end catch
                        } // end else
                    }) // end performUIUpdates
                    
                    if count == 0 {
                        self.flickrPhotoCollectionView.hidden = true
                    } else {
                        self.flickrPhotoCollectionView.hidden = false
                    } // end else 
                    
                    performUIUpdatesOnMain({
                        self.newCollectionButton.enabled = true
                    })
                }) // end get photos handler
            } // end if
            
        } else { // end if for title
            if let indexes = flickrPhotoCollectionView.indexPathsForSelectedItems() { // delete all of the photos
                for thisIndex in indexes {
                    let thisPhoto = fetchedResultsController!.objectAtIndexPath(thisIndex) as! LocationImage
                    self.fetchedResultsController!.managedObjectContext.deleteObject(thisPhoto)
                } // end for
            } // end if
            
            newCollectionButton.setTitle("New Collection", forState: .Normal)
        } // end else
    } // end function
    
    // remove the photos from the fetched results and coredata
    func clearImages(pin: LocationPin) {
  
        if let pins = pin.locationImage!.allObjects as? [LocationImage] { // delete the photos for the pin
            for photo in pins {
                self.fetchedResultsController!.managedObjectContext.deleteObject(photo)
            }
        } // end if
    } // end function
    
    // get more photos for pin and store them in coreData
    func getPhotos(pin: LocationPin, completionHandler: (success: Bool, count: Int, errorString: String?) -> Void) {
//        if (Reachability.isConnectedToNetwork()) {
        
            guard let latitude = pin.latitude as? Double, longitude = pin.longitude as? Double else {
                completionHandler(success: false, count: 0, errorString: "Could not get photos")
                return
            } // end guard
            
            FlickrClient.sharedInstance().retrievePhotosFromFlickr(latitude, longitude: longitude) { (success, photoURLs, error) in
                
                if success == false {
                    print("error")
                    completionHandler(success: false, count: 0, errorString: "There was an error retrieving results")
                    return
                }
                
                if photoURLs.count > 0 { // photos are returned, so add them to context
                    self.photoURLs = photoURLs
                    
                    for url in self.photoURLs {// add each url to context
                        
                        FlickrClient.sharedInstance().getPhotoImage(url, completionHandler: { (image, success) in
                            
                            let photoData = LocationImage(imageString: url, context: self.fetchedResultsController!.managedObjectContext)
                            photoData.locationPin = self.locationOfPin
                        }) // end closure
                    } // end for
                    
                    self.completeSearch()
                    
                    completionHandler(success: true, count: photoURLs.count, errorString: nil)
                } // end completion handler for retrivePhotosFromFlickr
            }

//        } else { // no network display error
//            self.displayEmptyAlert("", message: "No Network Connection Detected", actionTitle: "Dismiss")
//        }
    } // end function
    
    func displayEmptyAlert(headTitle: String?, message: String?, actionTitle: String?){ // used to create alert messages that are displayed to the user
        
        // run the alert in the main queue because it's a member of UIKit
        dispatch_async(dispatch_get_main_queue(), {()-> Void in
            
            let alert = UIAlertController(title: headTitle, message: message, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: actionTitle, style: .Default, handler: { action in
                
            }))
            self.presentViewController(alert, animated: true, completion: nil)
            
        }) // end image main queue completion handler
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

extension PhotoCollectionViewController: UICollectionViewDelegateFlowLayout, NSFetchedResultsControllerDelegate, UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let rowNumber = 3
        let layout = collectionViewLayout as! UICollectionViewFlowLayout
        let space = layout.sectionInset.left + layout.sectionInset.right + (layout.minimumInteritemSpacing * CGFloat(rowNumber - 1))
        let rowSize = Int((collectionView.bounds.width - space) / CGFloat(rowNumber))
        return CGSize(width: rowSize, height: rowSize)
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let photoCell = collectionView.cellForItemAtIndexPath(indexPath) { // if row is clicked, change the shade
            photoCell.highlighted = false
            photoCell.backgroundView!.alpha = 0.5
        }
        
        newCollectionButton.setTitle("Remove Selected Pictures", forState: .Normal)
    } // end function
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        if let photoCell = collectionView.cellForItemAtIndexPath(indexPath) {
            photoCell.highlighted = false
            photoCell.backgroundView!.alpha = 1.0
        } // end if
        
        if flickrPhotoCollectionView.indexPathsForSelectedItems() == nil {
            newCollectionButton.setTitle("New Collection", forState: .Normal)
        }
        if (indexes.count == 0) { // set the button back to "New Collection" if no photos have been selected
            newCollectionButton.setTitle("New Collection", forState: .Normal)
        }
    } // end function
    
    func controller(controller: NSFetchedResultsController,
                    didChangeObject anObject: AnyObject,
                                    atIndexPath indexPath: NSIndexPath?,
                                                forChangeType type: NSFetchedResultsChangeType,
                                                              newIndexPath: NSIndexPath?) {
        if let index = indexPath {
            switch (type) {
            
            case .Delete:
                deleteNeededVariables.append(index)
            case .Insert:
                flickrPhotoCollectionView.insertItemsAtIndexPaths([index])
            case .Update:
                flickrPhotoCollectionView.reloadItemsAtIndexPaths([index])
            default:
                print("there was a photo change that was not registered: \(index)")
            } // end switch
        } // end if
    } // end function
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        
        if deleteNeededVariables.count > 0 {
            flickrPhotoCollectionView.deleteItemsAtIndexPaths(deleteNeededVariables)
            deleteNeededVariables.removeAll()
        } // end if
    } // end function
} // end extension

extension PhotoCollectionViewController: UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let photoCell = collectionView.dequeueReusableCellWithReuseIdentifier("flickrPhotoCollectionViewCell", forIndexPath: indexPath) as! FlickrCollectionViewCell
        photoCell.backgroundView = nil // set background photo to be a gray color
        photoCell.backgroundColor = UIColor.lightGrayColor()
        photoCell.flickrActivityIndicator.hidden = true
        photoCell.userInteractionEnabled = true
        
        let imagePhoto = fetchedResultsController?.objectAtIndexPath(indexPath) as! LocationImage
        
        // load photos
        if (imagePhoto.image != nil) {
            let imageData = imagePhoto.image!
            let photo = UIImage(data: imageData)
            let view = UIImageView(image: photo)
            //photoCell.backgroundView = view
            photoCell.backgroundView = view
            photoCell.backgroundView!.alpha = 0.1
            if photoCell.selected == true {
                photoCell.backgroundView!.alpha = 0.1
            } else {
                photoCell.backgroundView!.alpha = 1.0
            } // end else
        } else {
            
            
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)) { () -> Void in
                photoCell.backgroundView = nil
                photoCell.flickrActivityIndicator.hidden = false
                photoCell.flickrActivityIndicator.startAnimating()
                
                FlickrClient.sharedInstance().getPhotoImage(imagePhoto.urlForImage!, completionHandler: { (image, success) in
                    
                    imagePhoto.image = image
                    
                    // once you have this, run the handler completionHandler!
                    dispatch_async(dispatch_get_main_queue(), {()-> Void in
                        // set image to cell on the main thread
                        let photo = UIImage(data: image!)
                        let view = UIImageView(image: photo)
                        //photoCell.backgroundView = view
                        photoCell.backgroundView = view
                        photoCell.backgroundView!.alpha = 0.1
                        if photoCell.selected == true {
                            photoCell.backgroundView!.alpha = 0.1
                        } else {
                            photoCell.backgroundView!.alpha = 1.0
                        } // end else
                        photoCell.flickrActivityIndicator.stopAnimating()
                        photoCell.flickrActivityIndicator.hidden = true
                        self.completeSearch()
                    }) // end image main queue completion handler
                })
            } // end closure
        }
        
        return photoCell
    } // end function
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        var count = 0
        
        if let objects = fetchedResultsController?.fetchedObjects {
            count = objects.count
        }
        
        return count
    } // end function
} // end extension