//
//  LocationImage.swift
//  VirtualTourist
//
//  Created by Reagan Wood on 8/9/16.
//  Copyright © 2016 RW Software. All rights reserved.
//

import Foundation
import CoreData


class LocationImage: NSManagedObject {

// Insert code here to add functionality to your managed object subclass

    convenience init(imageString: String, context : NSManagedObjectContext){
        
        // An EntityDescription is an object that has access to all
        // the information you provided in the Entity part of the model
        // you need it to create an instance of this class.
        if let ent = NSEntityDescription.entityForName("LocationImage",
                                                       inManagedObjectContext: context){
            self.init(entity: ent, insertIntoManagedObjectContext: context)
            self.urlForImage = imageString
        }else{
            fatalError("Unable to find Entity name!")
        }
        
    }

}
