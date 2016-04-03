/*
Copyright (C) 2015 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:
Shows how to lift operation-like objects in to the NSOperation world.
*/

import Foundation

private var URLSessionTaksOperationKVOContext = 0

class URLSessionTaskOperation: Operation {
    let task: NSURLSessionTask
    
    init(task: NSURLSessionTask) {
        assert(task.state == .Suspended, "Tasks must be suspended.")
        self.task = task
        super.init()
    }
    
    override func execute() {
        assert(task.state == .Suspended, "Task was resumed by something other than \(self).")

        task.addObserver(self, forKeyPath: "state", options: [], context: &URLSessionTaksOperationKVOContext)
        
        task.resume()
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        guard context == &URLSessionTaksOperationKVOContext else { return }
        
        if object === task && keyPath == "state" && task.state == .Completed {
            task.removeObserver(self, forKeyPath: "state")
            finish()
        }
    }
    
    override func cancel() {
        task.cancel()
        super.cancel()
    }
}
