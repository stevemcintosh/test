//
//  SettingsViewCell.swift
//  test
//
//  Created by Stephen McIntosh on 2/04/2016.
//  Copyright © 2016 Stephen McIntosh. All rights reserved.
//

import UIKit

class SettingsViewCell: UITableViewCell {
    @IBOutlet weak var topLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func configure(searchResult: [String : AnyObject]) {
        self.topLabel.text = "Hello Settings"
    }
}
