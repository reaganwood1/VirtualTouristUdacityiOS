//
//  PhotoAlbumMapViewController.swift
//  VirtualTourist
//
//  Created by Reagan Wood on 6/1/16.
//  Copyright © 2016 RW Software. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import MapKit

class PhotoAlbumMapViewController: UIViewController, UICollectionViewDelegate, MKMapViewDelegate,UICollectionViewDataSource{
    var photoURLs = [String]()
    var nsPin: NSManagedObject? // TODO: make this pin the goto pin
    var pin: MKAnnotation?
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var photoAlbumCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        mapView.delegate = self
        photoAlbumCollectionView.delegate = self
        photoAlbumCollectionView.dataSource = self
        photoAlbumCollectionView.reloadData()
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(photoURLs.count)
        return photoURLs.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        print(indexPath.row)
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ImageCell", forIndexPath: indexPath) as! FlickrCollectionViewCell
        cell.flickrActivityIndicator.startAnimating()
        
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)) { () -> Void in
            
            FlickrClient.sharedInstance().getPhotoImage(self.photoURLs[indexPath.row], completionHandler: { (image, success) in
                
                let realImage = UIImage(data: image!)
                
                // once you have this, run the handler completionHandler!
                dispatch_async(dispatch_get_main_queue(), {()-> Void in
//                    cell.flickrImage.image = realImage
//                    cell.flickrActivityIndicator.stopAnimating() // stop animating when picture is retrieved
//                    cell.flickrActivityIndicator.hidden = true
                }) // end image main queue completion handler
            })
        } // end closure
        
        return cell
    } // end function
} // end class