//
//  LocationPin.swift
//  VirtualTourist
//
//  Created by Reagan Wood on 8/9/16.
//  Copyright © 2016 RW Software. All rights reserved.
//

import Foundation
import CoreData


class LocationPin: NSManagedObject {

// Insert code here to add functionality to your managed object subclass
    // Insert code here to add functionality to your managed object subclass
    
    convenience init(latitude: Double, longitude: Double,  context : NSManagedObjectContext){
        
        // An EntityDescription is an object that has access to all
        // the information you provided in the Entity part of the model
        // you need it to create an instance of this class.
        if let ent = NSEntityDescription.entityForName("LocationPin",
                                                       inManagedObjectContext: context){
            self.init(entity: ent, insertIntoManagedObjectContext: context)
            self.latitude = latitude
            self.longitude = longitude
        }else{
            fatalError("Unable to find Entity name!")
        }
        
    }
    
    // source / inspiration - Jarrod Parkes, a Udacity instructor: https://github.com/jarrodparkes/ios-virtual-tourist/blob/master/VirtualTourist/Photo.swift
    func deletePhotos(context: NSManagedObjectContext) {
        if let photos = locationImage {
            for photo in photos {
                context.deleteObject(photo as! NSManagedObject)
            }
        }
    } // end function
}
