//
//  FlickrConvenience.swift
//  VirtualTourist
//
//  Created by Reagan Wood on 5/31/16.
//  Copyright © 2016 RW Software. All rights reserved.
//

import Foundation

extension FlickrClient {
   
    func retrievePhotosFromFlickr(latitude: Double, longitude: Double, completionHandler: (success: Bool, photoURLs: [String], error: String?) -> Void) {
        
        var photoURLArray = [String]()
        
        let methodParameters: [String:AnyObject] = [FlickrParameterKeys.Method: FlickParameterValues.GetPhotosMethod, FlickrParameterKeys.APIKey: FlickParameterValues.APIKey, FlickrParameterKeys.Extras: FlickParameterValues.MediumURL, FlickrParameterKeys.ResponseFormat: FlickParameterValues.ResponseFormat, FlickrParameterKeys.NoJSONCallback: FlickParameterValues.JSONCallback, FlickrParameterKeys.Bbox: bboxString(latitude, longitude: longitude)]
        
        taskForGetMethod(methodParameters) { (result, error) in
            
            if error == nil {
                print(result)
                if let photoDictionary = result[FlickrJSONResponseKeys.Photos] as? [String:AnyObject]{
                    print("success")
                    if let photoCountString = photoDictionary[FlickrJSONResponseKeys.TotalPages] as? String {
                        if let photoCountInt = Int(photoCountString) {
                            if photoCountInt > 0 {
                                if let photosDictionary = photoDictionary[FlickrJSONResponseKeys.Photo] as? [[String:AnyObject]]{
                                    
                                    var i: Int = 0
                                    while (i < photoCountInt && i < 16) {
                                        let photoInfo = photosDictionary[i] as [String:AnyObject]
                                        if let photoURL = photoInfo[FlickrJSONResponseKeys.MediumURL] as? String {
                                            photoURLArray.append(photoURL)
                                        } else {
                                            completionHandler(success: false, photoURLs: photoURLArray, error: nil)
                                        }
                                        i += 1
                                    }
                                    
                                    completionHandler(success: true, photoURLs: photoURLArray, error: "no error")
                                    
                                } else {
                                    completionHandler(success: false, photoURLs: photoURLArray, error: "not photos from dictionary could be retrieved")
                                }
                            } else {
                                completionHandler(success: false, photoURLs: photoURLArray, error: "photoCount was less than or equal to 0")
                            }
                        } else {
                            completionHandler(success: false, photoURLs: photoURLArray, error: "photoCount not available")
                        }
                    } else {
                        completionHandler(success: false, photoURLs: photoURLArray, error: "photoCount not available")
                    }
                } else {
                    completionHandler(success: false, photoURLs: photoURLArray, error: "could not parse into photos array")
                }
            } else {
                completionHandler(success: false, photoURLs: photoURLArray, error: "Could not get photo URLs")
            }
            
            
        }
    }
    
    func getPhotoImage (url: String, completionHandler: (image: NSData?, success: Bool) -> Void) {
        
        let nsURL = NSURL(string: url)
        if let imageData = NSData(contentsOfURL: nsURL!){
            completionHandler(image: imageData, success: true)
        } else {
            completionHandler(image: nil, success: false)
        }
    } // end function
    
    private func bboxString(latitude: Double, longitude: Double) -> String {
        // ensure bbox is bounded by minimum and maximums
        
            let minimumLon = max(longitude - FlickrConstants.SearchBBoxHalfWidth, FlickrConstants.SearchLonRange.0)
            let minimumLat = max(latitude - FlickrConstants.SearchBBoxHalfHeight,FlickrConstants.SearchLatRange.0)
            let maximumLon = min(longitude + FlickrConstants.SearchBBoxHalfWidth, FlickrConstants.SearchLonRange.1)
            let maximumLat = min(latitude + FlickrConstants.SearchBBoxHalfHeight, FlickrConstants.SearchLatRange.1)
            return "\(minimumLon),\(minimumLat),\(maximumLon),\(maximumLat)"
    }
}