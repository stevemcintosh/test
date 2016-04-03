/*
Copyright (C) 2015 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:
Contains the logic to parse a JSON file of https feed and return result
*/

import CoreLocation
import Foundation
import UIKit

/// A struct to represent a parsed search result.
struct ParsedSearchResult {
    // MARK: Properties.

    // MARK: Initialization
    let location: CLLocation?
    let placesOfInterest: [[String: AnyObject]]?
    init?(coords: [String: AnyObject], data: [
        [String: AnyObject]]) {
        self.placesOfInterest = data
        guard let latitude = (coords["lat"] as? NSString)?.doubleValue,
                let longitude = (coords["lng"] as? NSString)?.doubleValue else {
                return nil
        }
        location = CLLocation.init(latitude: latitude, longitude: longitude)
    }
}

class ParseSearchResultsOperation: Operation {
    let cacheFile: NSURL
    let completionHandler: (ParsedSearchResult) -> Void
    
    init(cacheFile: NSURL, completionHandler: (ParsedSearchResult) -> Void) {
        self.cacheFile = cacheFile
        self.completionHandler = completionHandler
        
        super.init()
        name = "Parse Search Results"
    }
    
    override func execute() {
        guard let stream = NSInputStream(URL: cacheFile) else {
            finish()
            return
        }
        
        stream.open()
        
        defer {
            stream.close()
        }
        
        do {
            let json = try NSJSONSerialization.JSONObjectWithStream(stream, options: []) as? [String: AnyObject]
            
            guard let coords = json?["coords"] as? [String: AnyObject],
                    let data = json?["data"] as? [[String: AnyObject]] else {
                finish()
                return
            }
            
            parseJSON(coords, data: data)

        }
        catch let jsonError as NSError {
            finishWithError(jsonError)
        }
    }
    
    private func parseJSON(coords: [String: AnyObject], data: [[String: AnyObject]]) {
        guard let parsedCoords = ParsedSearchResult(coords: coords, data: data) else {
            self.finishWithError(NSError(domain: "can't create file", code: -1, userInfo: nil))
            return
        }
        self.completionHandler(parsedCoords)
    }
}
