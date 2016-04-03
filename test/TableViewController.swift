//
//  TableViewController.swift
//  test
//
//  Created by Stephen McIntosh on 2/03/2016.
//  Copyright © 2016 Stephen McIntosh. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData

class TableViewController: UITableViewController, UISearchBarDelegate, UITextFieldDelegate {
    
    // IB outlets
    @IBOutlet weak var searchBar: UISearchBar!
    
    var searchString: String?
    var searchLocation: CLLocation?
    var searchResults: [[String : AnyObject]]?
    let operationQueue = OperationQueue()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let navBar = self.tabBarController?.navigationItem else { return }
        navBar.title = "Spots"

        self.searchBar.text = "wembley"
        self.searchBar.delegate = self
        
        refreshControl = UIRefreshControl()
        refreshControl?.tintColor = UIColor.redColor()
        refreshControl?.addTarget(self, action: #selector(getResultsForSearch), forControlEvents: .ValueChanged)
        if let refreshControl = refreshControl {
            self.tableView.addSubview(refreshControl)
        }
        
        tableView.autoresizesSubviews = true
        tableView.autoresizingMask = .FlexibleHeight
        tableView.estimatedRowHeight = 100.0
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.delegate = self
        
        tableView.dataSource = self
        
        let operation = CreateJSONCacheOperation { completionHandler in
            dispatch_async(dispatch_get_main_queue()) {
                self.getResultsForSearch()
            }
        }
        operationQueue.addOperation(operation)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func getResultsForSearch(userInitiated: Bool = true) {
        
        self.refreshControl?.beginRefreshing()
        
        if let searchText = self.searchBar.text {
            let getSearchResultsOperation = GetSearchResultsOperation(searchText: searchText) { parsedSearchResult in
                
                guard let searchLocation = parsedSearchResult.location,
                let searchResults = parsedSearchResult.placesOfInterest where parsedSearchResult.placesOfInterest!.count > 0 else {
                    self.updateUI()
                    return
                }
                
                self.searchLocation = searchLocation
                self.searchResults = searchResults
                
                dispatch_async(dispatch_get_main_queue()) {
                    self.updateUI()
                }
            }
            
            getSearchResultsOperation.userInitiated = userInitiated
            operationQueue.addOperation(getSearchResultsOperation)
        }
        else {
            let when = dispatch_time(DISPATCH_TIME_NOW, Int64(0.3 * Double(NSEC_PER_SEC)))
            dispatch_after(when, dispatch_get_main_queue()) {
                self.updateUI()
            }
        }
    }
    
    private func updateUI() {
        tableView.reloadData()
        self.refreshControl?.endRefreshing()
    }
    
    // MARK: TableViewDataSourceDelegate methods

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.searchResults?.count ?? 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let row = indexPath.row
        let cell = tableView.dequeueReusableCellWithIdentifier("cellWithSightTileView", forIndexPath: indexPath) as! TableViewCell
        
        if let searchResult = self.searchResults?[row] {
            cell.configure(searchResult)
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        let operation = BlockOperation {
            self.performSegueWithIdentifier("showDetail", sender: nil)
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
        guard let navigationVC = segue.destinationViewController as? UINavigationController,
            detailVC = navigationVC.viewControllers.first as? DetailViewController else {
                return
        }
        detailVC.queue = operationQueue
        
        if let indexPath = tableView.indexPathForSelectedRow {
            detailVC.justParkSearchLocation = self.searchLocation
            detailVC.justParkResult = self.searchResults?[indexPath.row]
        }
    }

// MARK: -
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
    }
    
// MARK: - UISearchBarDelegate -
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.characters.count > 0 {
            self.searchBar.text = searchText.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        }
    }
    
    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {

        UIView.animateWithDuration(0.25, animations: {
            self.tableView.backgroundColor = UIColor.lightGrayColor()
            self.tableView.alpha = 0.85
        })
        return true
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        self.searchBar.becomeFirstResponder()
    }
    
    func searchBarShouldEndEditing(searchBar: UISearchBar) -> Bool {
    
        UIView.animateWithDuration(0.25, animations: {
            self.tableView.backgroundColor = UIColor.whiteColor()
            self.tableView.alpha = 1.0
        })
        return true
    }

    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        self.searchBar.resignFirstResponder()
    }

    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        getResultsForSearch()
        self.searchBar.resignFirstResponder()
    }

    // MARK: UITextFieldDelegate methds
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.searchBar.text = textField.text
        getResultsForSearch()
        return true
    }
    
}

