//
//  FlickrConvenience.swift
//  VirtualTourist
//
//  Created by Reagan Wood on 5/31/16.
//  Copyright © 2016 RW Software. All rights reserved.
//

import Foundation

extension FlickrClient {
   
    func retrievePhotosFromFlickr(latitude: Double, longitude: Double, completionHandler: (success: Bool, error: String) -> Void) {
        let methodParameters: [String:AnyObject] = [FlickrParameterKeys.Method: FlickParameterValues.GetPhotosMethod, FlickrParameterKeys.APIKey: FlickParameterValues.APIKey, FlickrParameterKeys.Extras: FlickParameterValues.MediumURL, FlickrParameterKeys.ResponseFormat: FlickParameterValues.ResponseFormat, FlickrParameterKeys.NoJSONCallback: FlickParameterValues.JSONCallback, FlickrParameterKeys.Bbox: bboxString(latitude, longitude: longitude)]
        
        taskForGetMethod(methodParameters) { (result, error) in
            
            if error == nil {
                print(result)
                if let photoDictionary = result[FlickrJSONResponseKeys.Photos] as? [String:AnyObject]{
                    print("success")
                    if let photoCountString = photoDictionary[FlickrJSONResponseKeys.TotalPages] as? String {
                        if let photoCountInt = Int(photoCountString) {
                            print("fucktheFuck")
                        }
                    }
                } else {
                    completionHandler(success: false, error: "could not parse into photos array")
                }
            } else {
                completionHandler(success: false, error: "Could not get photo URLs")
            }
            
            
        }
    }
    
    private func bboxString(latitude: Double, longitude: Double) -> String {
        // ensure bbox is bounded by minimum and maximums
        
            let minimumLon = max(longitude - FlickrConstants.SearchBBoxHalfWidth, FlickrConstants.SearchLonRange.0)
            let minimumLat = max(latitude - FlickrConstants.SearchBBoxHalfHeight,FlickrConstants.SearchLatRange.0)
            let maximumLon = min(longitude + FlickrConstants.SearchBBoxHalfWidth, FlickrConstants.SearchLonRange.1)
            let maximumLat = min(latitude + FlickrConstants.SearchBBoxHalfHeight, FlickrConstants.SearchLatRange.1)
            return "\(minimumLon),\(minimumLat),\(maximumLon),\(maximumLat)"
    }
}