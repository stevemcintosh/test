//
//  SettingsDetailViewController.swift
//  test
//
//  Created by Stephen McIntosh on 2/04/2016.
//  Copyright © 2016 Stephen McIntosh. All rights reserved.
//

import UIKit

class SettingsDetailViewController: UITableViewController {
    var settings: [[String : AnyObject]] {
        get {
            return [["Notifications" : true],
                    ["Report a problem" : "https://"],
                    ["Help" : "https://"] ]
        }
    }
    let operationQueue = OperationQueue()
    var queue: OperationQueue?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    // MARK: TableViewDataSourceDelegate methods
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.settings.count ?? 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let row = indexPath.row
        let cell = tableView.dequeueReusableCellWithIdentifier("settingsDetailCell", forIndexPath: indexPath) as! SettingsDetailViewCell
        
        guard let searchResult = self.settings[row] as? [String : AnyObject] else { return SettingsDetailViewCell.init() }
        cell.configure(searchResult)
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let operation = BlockOperation {
        }
        
        operation.addCondition(MutuallyExclusive<UIViewController>())
        
        let blockObserver = BlockObserver { _, errors in
            /*
             If the operation errored (ex: a condition failed) then the segue
             isn't going to happen. We shouldn't leave the row selected.
             */
            if !errors.isEmpty {
                dispatch_async(dispatch_get_main_queue()) {
                    tableView.deselectRowAtIndexPath(indexPath, animated: true)
                }
            }
        }
        
        operation.addObserver(blockObserver)
        
        operationQueue.addOperation(operation)
    }
}
