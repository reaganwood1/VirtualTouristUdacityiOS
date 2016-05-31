//
//  LocationImage+CoreDataProperties.swift
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

extension LocationImage {

    @NSManaged var image: NSData?
    @NSManaged var locationPin: LocationPin?

}
