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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        longPressGestureActivated()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func didLongPress() {
        print("long pressed")
    }
    
    func longPressGestureActivated () {
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: "didLongPress")
        longPressGesture.minimumPressDuration = 1
        mapView.addGestureRecognizer(longPressGesture)
        
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
    }
    
}

