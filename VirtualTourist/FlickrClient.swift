//
//  FlickrClient.swift
//  VirtualTourist
//
//  Created by Reagan Wood on 5/31/16.
//  Copyright © 2016 RW Software. All rights reserved.
//

import Foundation


// MARK: Shared Instance
class FlickrClient: NSObject {

    // shared session
    var session = NSURLSession.sharedSession()

    func taskForGetMethod(methodParameters: [String:AnyObject], completionHandlerForPOST:(result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionTask {
        
        let request = NSURLRequest(URL: flickrURLFromParameters(methodParameters))
        let url = flickrURLFromParameters(methodParameters)
        print(url)
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            // function for creating error messages
            func sendError(error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey: error]
                completionHandlerForPOST(result: nil, error: NSError(domain: "taskForGetMethod", code: 1, userInfo: userInfo))
            }
            
            // check for error
            guard (error == nil) else {
                sendError("There was an error with your request: \(error)")
                return
            }
            
            // check for successful status code
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            
            // get the data
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            // parse the data
            self.parseJSONData(data, completionHandler: completionHandlerForPOST)
            
        } // end closure
        
        // resume the task
        task.resume()
        
        return task
    }
    
    // function parses JSON data
    func parseJSONData (data: NSData, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        
        // Parse the JSON data and return through the completion handler
        var parsedResult: AnyObject!
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            completionHandler(result: parsedResult, error: nil)
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandler(result: nil, error: NSError(domain: "parseJSONData", code: 1, userInfo: userInfo))
        }
    }
    
    // MARK: Helper for Creating a URL from Parameters
    
    private func flickrURLFromParameters(parameters: [String:AnyObject]) -> NSURL {
        
        let components = NSURLComponents()
        components.scheme = FlickrConstants.Scheme
        components.host = FlickrConstants.Host
        components.path = FlickrConstants.Path
        components.queryItems = [NSURLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = NSURLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.URL!
    }
    
class func sharedInstance() -> FlickrClient {
    struct Singleton {
        static var sharedInstance = FlickrClient()
    }
    return Singleton.sharedInstance
}

}