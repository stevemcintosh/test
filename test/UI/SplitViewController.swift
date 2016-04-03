//
//  SplitViewController.swift
//  test
//
//  Created by Stephen McIntosh on 4/03/2016.
//  Copyright © 2016 Stephen McIntosh. All rights reserved.
//

import UIKit

class SplitViewController: UISplitViewController {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        preferredDisplayMode = .AllVisible
        delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateMaximumPrimaryColumnWidthBasedOnSize(view.bounds.size)
    }
    
    func updateMaximumPrimaryColumnWidthBasedOnSize(size: CGSize) {
        if size.width < UIScreen.mainScreen().bounds.width || size.width < size.height {
            maximumPrimaryColumnWidth = 480.0
        } else {
            maximumPrimaryColumnWidth = UISplitViewControllerAutomaticDimension
        }
    }

    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        updateMaximumPrimaryColumnWidthBasedOnSize(size)
    }
}

extension SplitViewController: UISplitViewControllerDelegate {
    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController: UIViewController, ontoPrimaryViewController primaryViewController: UIViewController) -> Bool {
        guard let navigation = secondaryViewController as? UINavigationController else { return false }
        guard let detail = navigation.viewControllers.first as? DetailViewController else { return false }
        
        return detail.justParkResult == nil
    }
}
