//
//  FlickrConstants.swift
//  VirtualTourist
//
//  Created by Reagan Wood on 5/31/16.
//  Copyright © 2016 RW Software. All rights reserved.
//

import Foundation

extension FlickrClient {
    
    struct FlickrConstants {
        //static let BASE_URL = "https://api.flickr.com/services/rest/"
        static let Scheme = "https"
        static let Host = "api.flickr.com"
        static let Path = "/services/rest"
        
        // Bbox constants
        static let SearchBBoxHalfWidth = 1.0
        static let SearchBBoxHalfHeight = 1.0
        static let SearchLatRange = (-90.0, 90.0)
        static let SearchLonRange = (-180.0, 180.0)
    }
    
    struct FlickrJSONResponseKeys {
        static let Photos = "photos"
        static let Photo = "photo"
        static let Pages = "pages"
        static let Page = "page"
        static let TotalPages = "total"
        static let PhotoID = "id"
        static let PhotoTitle = "title"
        static let MediumURL = "url_m"
    }
    
    struct FlickrParameterKeys {
        static let Method = "method"
        static let APIKey = "api_key"
        static let Bbox = "bbox"
        static let SafeSearch = "safe_search"
        static let ContentType = "content_type"
        static let ContentPerPage = "per_page"
        static let ReturnNumberPage = "page"
        static let Extras = "extras"
        static let ResponseFormat = "format"
        static let NoJSONCallback = "nojsoncallback"
    }
    
    struct FlickParameterValues {
        static let GetPhotosMethod = "flickr.photos.search"
        static let APIKey = "bdd17c2119f8047535c6c51401868df1"
        static let ResponseFormat = "json"
        static let DisableJSONCallback = "1"
        static let MediumURL = "url_m"
        static let JSONCallback = "1"
        static let UseSafeSearch = "1"
        static let PER_Page = "100"
    }
}