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
    
    // MARK: Collection View
    var photoArray = [LocationImage]()
    
    // MARK: Mapview Delegate
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let pinReuseID = "pin" // set reuse id
        
        // deque the pin to be resued
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(pinReuseID) as? MKPinAnnotationView
        
        // if there is no pin, create a pin
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: pinReuseID)
            pinView!.pinTintColor = UIColor.redColor()
        } else {
            pinView!.annotation = annotation
        }
        
        return pinView
    } // end function
    
    //MARK: Cored Data Methods
    
}

extension PhotoCollectionViewController: UICollectionViewDataSource {
    
    // gets the number of photos in the collection
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoArray.count
    } // end function
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let photoCell = collectionView.dequeueReusableCellWithReuseIdentifier("FlickrCollectionViewCell", forIndexPath: indexPath) as! FlickrCollectionViewCell
        
        let photo = photoArray[indexPath.row] // get the photo for the row
        if let photoData = photo.image {
            
        }
        return photoCell
    }
}