//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Reagan Wood on 5/31/16.
//  Copyright © 2016 RW Software. All rights reserved.
//

import Foundation
import MapKit
import UIKit
import CoreData

class PhotoAlbumViewController: UICollectionViewController {
    
    var pin: MKAnnotation?
    var nsPin: NSManagedObject? // TODO: make this pin the goto pin
    var photos = [NSManagedObject]()
    var fetchedResultsController: NSFetchedResultsController?
    
    override func viewDidLoad() {
        
        
        //checkForPhotos()
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
                // Create the cell
                let cell = collectionView.dequeueReusableCellWithReuseIdentifier("tempCell", forIndexPath: indexPath)
                // Sync notebook -> cell
                
                return cell
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
//    func checkForPhotos() {
//        
//        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
//        let stackContext = delegate.stack.context
//        let predicate = NSPredicate(format: "locationPin = %@", argumentArray: [pin!])
//        let appIcon = UIImage(contentsOfFile: "appIcon")
//        //let image = LocationImage(image: UIImageJPEGRepresentation(appIcon!, 1)! , context: stackContext)
//        //image.locationPin
//        // Get the stack
//        let stack = delegate.stack
//        
//        // Create a fetchrequest
//        let fr = NSFetchRequest(entityName: "LocationImage")
//       // fr.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true),
//                              //NSSortDescriptor(key: "creationDate", ascending: false)]
//        fr.sortDescriptors = [NSSortDescriptor(key: "locationImage", ascending: false)]
//
//        let pred = NSPredicate(format: "locationPin = %@", argumentArray: [nsPin!])
//        fr.predicate =  pred
//        // Create the FetchedResultsController
//        fetchedResultsController = NSFetchedResultsController(fetchRequest: fr,
//                                                              managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
//    }
    
//    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        
//        if let fc = fetchedResultsController{
//            print(fc.fetchedObjects?.count)
//            return fc.sections![section].numberOfObjects;
//        }else{
//            return 0
//        }
//    } // end function
    
//    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
//        
//
//    }
    
//    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
//        
//        // Find the right image for this indexpath
//        let nb = fetchedResultsController!.objectAtIndexPath(indexPath) as! LocationImage
//        
//        // Create the cell
//        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("tempCell", forIndexPath: indexPath)
//        // Sync notebook -> cell
//        
//        let imageData = UIImage(data: nb.image!)
//        
//        
//        return cell
//    }
}