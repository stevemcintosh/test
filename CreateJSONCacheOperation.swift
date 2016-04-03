
import UIKit

class CreateJSONCacheOperation: Operation {
    // MARK: Properties
    let completionHandler: () -> Void
    
    // MARK: Initialization
    init(completionHandler: () -> Void) {
        self.completionHandler = completionHandler
        
        super.init()
        
        // We only want one of these going at a time.
        addCondition(MutuallyExclusive<CreateJSONCacheOperation>())
    }
    
    override func execute() {
        let cachesFolder = try! NSFileManager.defaultManager().URLForDirectory(.CachesDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true)
        
        let storeURL = cachesFolder.URLByAppendingPathComponent("searchResults.json")
        let storePath = storeURL.path!
        let result = NSFileManager.defaultManager().createFileAtPath(storePath, contents: nil, attributes: nil)
        
        if result == true {
            completionHandler()
        } else {
            finishWithError(NSError(domain: "can't create file", code: -1, userInfo: nil))
        }
    }
    
    override func finished(errors: [NSError]) {
        guard let firstError = errors.first where userInitiated else { return }

        /*
            We failed to load the model on a user initiated operation try and present
            an error.
        */
        
        let alert = AlertOperation()

        alert.title = "Unable to create JSON cache file"
        
        alert.message = "An error occurred while creating the JSON cache file. \(firstError.localizedDescription)."
        
        // No custom action for this button.
        alert.addAction("Retry Later", style: .Cancel)
        
        let handler = completionHandler
        
        alert.addAction("Retry Now") { alertOperation in
            let retryOperation = CreateJSONCacheOperation(completionHandler: handler)

            retryOperation.userInitiated = true
            
            alertOperation.produceOperation(retryOperation)
        }

        produceOperation(alert)
    }
}
