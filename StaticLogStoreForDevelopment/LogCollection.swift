//
//  LogCollection.swift
//  test
//
//  Created by Stephen McIntosh on 4/03/2016.
//  Copyright © 2016 Stephen McIntosh. All rights reserved.
//

import Foundation
import UIKit

public class LogCollection {
    
    // MARK: - Private
    
    private var logs = [NSDate: BaseLog]()
    
    func dictionaryRepresentation() -> Dictionary <NSDate, NSCoding> {
        return logs
    }
    
    // MARK: - Public
    
    public init() {}
    
    /// Adds a BaseLog or any of its subclasses to the collection.
    public func addLog(log: BaseLog) {
        logs[log.date] = log
    }
    
    /// Removes a BaseLog or any of its subclasses from the collection.
    public func removeLog(log: BaseLog) {
        logs[log.date] = nil
    }
    
    /// Returns an array of BaseLog or any of its subclasses sorted by date of creation.
    public func sortedLogs(ordered: NSComparisonResult) -> [BaseLog] {
        let allLogs = logs.values
        let sorted = allLogs.sort { return $0.date.compare($1.date) == ordered }
        return sorted
    }
    
}