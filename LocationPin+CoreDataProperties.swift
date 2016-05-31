//
//  LocationPin+CoreDataProperties.swift
//  VirtualTourist
//
//  Created by Reagan Wood on 5/30/16.
//  Copyright © 2016 RW Software. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension LocationPin {

    @NSManaged var latitude: NSNumber?
    @NSManaged var longitude: NSNumber?
    @NSManaged var locationImage: NSSet?

}
