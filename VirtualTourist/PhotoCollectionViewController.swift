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
        
        if (fetchedResultsController!.fetchedObjects?.count == 0) {
            
            if let mapPin = locationOfPin {
                newCollectionButton.enabled = false
                getPhotos(mapPin, completionHandler: { (success, count, errorString) in
                    performUIUpdatesOnMain({ 
                        if success == false {
                            self.newCollectionButton.enabled = true
                            print("error in getPhotos")
                        } else {
                            do {
                                try self.fetchedResultsController!.managedObjectContext.save()
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
                    
                    self.newCollectionButton.enabled = true
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
                
                newCollectionButton.enabled = false
                
                clearImages(locPin)
                
                getPhotos(locPin, completionHandler: { (success, count, errorString) in
                    
                    performUIUpdatesOnMain({ 
                        if success == false {
                            self.newCollectionButton.enabled = true
                            print("error")
                        } else {
                            do {
                                try self.fetchedResultsController!.managedObjectContext.save()
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
                    
                    self.newCollectionButton.enabled = true
                }) // end get photos handler
            } // end if
            
        } else { // end if for title
            if let indexes = flickrPhotoCollectionView.indexPathsForSelectedItems() {
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
  
        if let pins = pin.locationImage!.allObjects as? [LocationImage] {
            for photo in pins {
                self.fetchedResultsController!.managedObjectContext.deleteObject(photo)
            }
        } // end if
    } // end function
    
    // get more photos for pin and store them in coreData
    func getPhotos(pin: LocationPin, completionHandler: (success: Bool, count: Int, errorString: String?) -> Void) {
        
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
            
            if photoURLs.count > 0 {
                self.photoURLs = photoURLs
                
                for url in self.photoURLs {
                    
                    FlickrClient.sharedInstance().getPhotoImage(url, completionHandler: { (image, success) in
                        
                        let photoData = LocationImage(image: image!, context: self.fetchedResultsController!.managedObjectContext)
                        photoData.locationPin = self.locationOfPin
                    }) // end closure
                } // end for
                
                performUIUpdatesOnMain({ 
                    self.completeSearch()
                    self.flickrPhotoCollectionView.reloadData()
                })
                
                
                
                
                
                
                
//                let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
//                let stackContext = appDelegate.stack.context
//                let fetchedRequest = NSFetchRequest(entityName: "LocationImage")
//                
//                var images: [NSManagedObject]
//                // Create a fetchrequest
//                let fr = NSFetchRequest(entityName: "LocationImage")
//                fr.sortDescriptors = []
//                
//                do {
//                    let results = try stackContext.executeFetchRequest(fetchedRequest)
//                    images = results as! [NSManagedObject]
//                } catch {
//                    
//                }
//                print(self.locationOfPin.locationImage?.allObjects)
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                completionHandler(success: true, count: photoURLs.count, errorString: nil)
            } // end completion handler for retrivePhotosFromFlickr
        }
    } // end function
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
        if let photoCell = collectionView.cellForItemAtIndexPath(indexPath) {
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
        
        //photoCell.flickrActivityIndicator.stopAnimating()
        
        photoCell.userInteractionEnabled = true
        
//        if let imagePhoto = fetchedResultsController?.objectAtIndexPath(indexPath) as! LocationImage {
//        
//        }
        
        let imagePhoto = fetchedResultsController?.objectAtIndexPath(indexPath) as! LocationImage
        let imageData = imagePhoto.image
        let photo = UIImage(data: imageData!)
        let view = UIImageView(image: photo)
        photoCell.backgroundView = view
        photoCell.backgroundView!.alpha = 0.1
        if photoCell.selected == true {
            photoCell.backgroundView!.alpha = 0.1
        } else {
            photoCell.backgroundView!.alpha = 1.0
        } // end else
        
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