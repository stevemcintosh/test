/*
Copyright (C) 2015 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:
This file shows how operations can be composed together to form new operations.
*/

import Foundation

class GroupOperation: Operation {
    private let internalQueue = OperationQueue()
    private let startingOperation = NSBlockOperation(block: {})
    private let finishingOperation = NSBlockOperation(block: {})

    private var aggregatedErrors = [NSError]()
    
    convenience init(operations: NSOperation...) {
        self.init(operations: operations)
    }
    
    init(operations: [NSOperation]) {
        super.init()
        
        internalQueue.suspended = true
        internalQueue.delegate = self
        internalQueue.addOperation(startingOperation)

        for operation in operations {
            internalQueue.addOperation(operation)
        }
    }
    
    override func cancel() {
        internalQueue.cancelAllOperations()
        super.cancel()
    }
    
    override func execute() {
        internalQueue.suspended = false
        internalQueue.addOperation(finishingOperation)
    }
    
    func addOperation(operation: NSOperation) {
        internalQueue.addOperation(operation)
    }
    
    /**
        Note that some part of execution has produced an error.
        Errors aggregated through this method will be included in the final array
        of errors reported to observers and to the `finished(_:)` method.
    */
    final func aggregateError(error: NSError) {
        aggregatedErrors.append(error)
    }
    
    func operationDidFinish(operation: NSOperation, withErrors errors: [NSError]) {
        // For use by subclassers.
    }
}

extension GroupOperation: OperationQueueDelegate {
    final func operationQueue(operationQueue: OperationQueue, willAddOperation operation: NSOperation) {
        assert(!finishingOperation.finished && !finishingOperation.executing, "cannot add new operations to a group after the group has completed")
        
        /*
            Some operation in this group has produced a new operation to execute.
            We want to allow that operation to execute before the group completes,
            so we'll make the finishing operation dependent on this newly-produced operation.
        */
        if operation !== finishingOperation {
            finishingOperation.addDependency(operation)
        }
        
        /*
            All operations should be dependent on the "startingOperation".
            This way, we can guarantee that the conditions for other operations
            will not evaluate until just before the operation is about to run.
            Otherwise, the conditions could be evaluated at any time, even
            before the internal operation queue is unsuspended.
        */
        if operation !== startingOperation {
            operation.addDependency(startingOperation)
        }
    }
    
    final func operationQueue(operationQueue: OperationQueue, operationDidFinish operation: NSOperation, withErrors errors: [NSError]) {
        aggregatedErrors.appendContentsOf(errors)
        
        if operation === finishingOperation {
            internalQueue.suspended = true
            finish(aggregatedErrors)
        }
        else if operation !== startingOperation {
            operationDidFinish(operation, withErrors: errors)
        }
    }
}