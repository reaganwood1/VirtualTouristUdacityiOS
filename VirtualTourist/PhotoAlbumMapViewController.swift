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

class PhotoAlbumMapViewController: UIViewController, UICollectionViewDelegate, MKMapViewDelegate, UICollectionViewDataSource{
    var numberOfPhotos: Int?
    var photos = [UIImage]()
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var photoAlbumCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        mapView.delegate = self
        photoAlbumCollectionView.delegate = self
        loadPhotos()
    }
    
    func loadPhotos () {
       
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        return UICollectionViewCell()
    }
    
    
}