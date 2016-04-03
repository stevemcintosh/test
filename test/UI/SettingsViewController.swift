//
//  SettingsViewController.swift
//  test
//
//  Created by Stephen McIntosh on 2/04/2016.
//  Copyright © 2016 Stephen McIntosh. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {
    
    var settings: [[String : AnyObject]] {
        get {
            return [["Notifications" : true],
                    ["Report a problem" : "https://"],
                    ["Help" : "https://"] ]
        }
    }
    let operationQueue = OperationQueue()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let navBar = self.tabBarController?.navigationItem else { return }
        navBar.title = "Settings"
    }
    
    // MARK: TableViewDataSourceDelegate methods
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.settings.count ?? 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let row = indexPath.row
        let cell = tableView.dequeueReusableCellWithIdentifier("settingsCell", forIndexPath: indexPath) as! SettingsViewCell
        
        guard let searchResult = self.settings[row] as? [String : AnyObject] else { return SettingsViewCell.init() }
        cell.configure(searchResult)
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let operation = BlockOperation {
            self.performSegueWithIdentifier("showSettings", sender: nil)
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let detailVC = segue.destinationViewController as? SettingsDetailViewController else {
                return
        }
        detailVC.queue = operationQueue
        
        if let indexPath = tableView.indexPathForSelectedRow {
//            detailVC.justParkResult = self.settings[indexPath.row]
        }
    }
}
