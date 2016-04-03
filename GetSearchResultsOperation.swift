import UIKit

/// A composite `Operation` to both download and parse json data.
class GetSearchResultsOperation: GroupOperation {
    // MARK: Properties
    
    let searchText: String
    let completionHandler: (ParsedSearchResult) -> Void
    
    let downloadOperation: DownloadSearchResultsOperation
    let parseOperation: ParseSearchResultsOperation
   
    private var hasProducedAlert = false
    
    init(searchText: String, completionHandler: (ParsedSearchResult) -> Void) {
        self.searchText     = searchText
        self.completionHandler = completionHandler
        
        let cachesFolder = try! NSFileManager.defaultManager().URLForDirectory(.CachesDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true)
        let cacheFileURL = cachesFolder.URLByAppendingPathComponent("searchResults.json")
        
        downloadOperation   = DownloadSearchResultsOperation(cacheFile: cacheFileURL, searchText: searchText)
        parseOperation      = ParseSearchResultsOperation(cacheFile: cacheFileURL) { parsedSearchResult in
            completionHandler(parsedSearchResult)
        }
        
        parseOperation.addDependency(downloadOperation)
        
        super.init(operations: [downloadOperation, parseOperation])

        name = "Get Search Results"
    }
    
    override func operationDidFinish(operation: NSOperation, withErrors errors: [NSError]) {
        if let firstError = errors.first where (operation === downloadOperation || operation === parseOperation) {
            produceAlert(firstError)
        }
    }
    
    private func produceAlert(error: NSError) {
        if hasProducedAlert { return }
        
        let alert = AlertOperation()
        
        let errorReason = (error.domain, error.code, error.userInfo[OperationConditionKey] as? String)
        
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
                alert.message = "Cannot download json data. Try again later."

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
