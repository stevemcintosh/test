import Foundation
import UIKit

/// A composite `Operation` to both download and parse json data.
class GetTileImageOperation: GroupOperation {
    // MARK: Properties
    
    let imageURL: NSURL
    let completionHandler: (TileImageResult?) -> Void
    let downloadTileImageOperation: DownloadTileImageOperation
    
    private var hasProducedAlert = false
    
    init(imageURL: NSURL, completionHandler: (TileImageResult?) -> Void) {
        self.imageURL = imageURL
        self.completionHandler = completionHandler

        downloadTileImageOperation = DownloadTileImageOperation(imageURL: imageURL) { parsedImageResult in
            completionHandler(parsedImageResult)
        }
        
        let reachabilityCondition = ReachabilityCondition(host: imageURL)
        downloadTileImageOperation.addCondition(reachabilityCondition)
        
        let networkObserver = NetworkObserver()
        downloadTileImageOperation.addObserver(networkObserver)
        
        super.init(operations: [downloadTileImageOperation])
        name = "Get Tile Image"
        
    }
    
    override func operationDidFinish(operation: NSOperation, withErrors errors: [NSError]) {
        if let firstError = errors.first where (operation === downloadTileImageOperation) {
            produceAlert(firstError)
        }
    }
    
    private func produceAlert(error: NSError) {
        /*
         We only want to show the first error, since subsequent errors might
         be caused by the first.
         */
        if hasProducedAlert { return }
        
        let alert = AlertOperation()
        
        let errorReason = (error.domain, error.code, error.userInfo[OperationConditionKey] as? String)
        
        // These are examples of errors for which we might choose to display an error to the user
        let failedReachability = (OperationErrorDomain, OperationErrorCode.ConditionFailed, ReachabilityCondition.name)
        
        let failedJSON = (NSCocoaErrorDomain, NSPropertyListReadCorruptError, nil as String?)
        
        switch errorReason {
            
        case failedReachability:
            // We failed because the network isn't reachable.
            let hostURL = error.userInfo[ReachabilityCondition.hostKey] as! NSURL
            
            alert.title = "Unable to Connect"
            alert.message = "Cannot connect to \(hostURL.host!). Make sure your device is connected to the internet and try again."
            
        case failedJSON:
            // We failed because the JSON was malformed.
            alert.title = "Unable to Download"
            alert.message = "Cannot download image data. Try again later."
            
        default:
            return
        }
        
        produceOperation(alert)
        hasProducedAlert = true
    }
}

// Operators to use in the switch statement.
private func ~=(lhs: (String, Int, String?), rhs: (String, Int, String?)) -> Bool {
    return lhs.0 ~= rhs.0 && lhs.1 ~= rhs.1 && lhs.2 == rhs.2
}

private func ~=(lhs: (String, OperationErrorCode, String), rhs: (String, Int, String?)) -> Bool {
    return lhs.0 ~= rhs.0 && lhs.1.rawValue ~= rhs.1 && lhs.2 == rhs.2
}