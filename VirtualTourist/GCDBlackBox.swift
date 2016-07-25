//
//  GCDBlackBox.swift
//  VirtualTourist
//
//  Created by Reagan Wood on 7/24/16.
//  Copyright © 2016 RW Software. All rights reserved.
//

import Foundation

func performUIUpdatesOnMain(updates: () -> Void) {
    dispatch_async(dispatch_get_main_queue()) {
        updates()
    }
}