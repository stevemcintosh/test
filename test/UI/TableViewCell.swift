//
//  TableViewCell.swift
//  test
//
//  Created by Stephen McIntosh on 26/03/2016.
//  Copyright © 2016 Stephen McIntosh. All rights reserved.
//

import UIKit
import SightRateKit

class TableViewCell: UITableViewCell {

    @IBOutlet weak var sightTileView: SightTileView!
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var bottomLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configure(searchResult: [String : AnyObject]) {
        
        self.sightTileView.setValue(searchResult["feedback"]?["rating"] as! Double / 10.0, forKey: "rating")
        self.sightTileView.setValue(3.0, forKey: "lineWidth")
        
        var urlStrWithZoom = searchResult["photos"]?["google_map"] as? String
        urlStrWithZoom = urlStrWithZoom?.stringByReplacingOccurrencesOfString("zoom=15", withString: "zoom=10")
        urlStrWithZoom = urlStrWithZoom?.stringByReplacingOccurrencesOfString("size=640x640", withString: "size=83x83")
        if urlStrWithZoom == nil {
            urlStrWithZoom = searchResult["photos"]?["google_map"] as? String
        }
        if let url = NSURL(string: urlStrWithZoom!) {
            let indicator: UIActivityIndicatorView  = UIActivityIndicatorView.init(activityIndicatorStyle: .White)
            indicator.center = self.sightTileView.center
            self.sightTileView.addSubview(indicator)
            indicator.startAnimating()

            let _ = GetTileImageOperation(imageURL: url) { tileImage in
                if let image = tileImage?.image {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.sightTileView.image = image
                        indicator.stopAnimating()
                    }
                } else {
                    indicator.stopAnimating()
                }
                
            }
        }
        self.topLabel.text = searchResult["title"] as? String
        if let spacesToRent = searchResult["spaces_to_rent"] as? CustomStringConvertible {
            self.bottomLabel.text = spacesToRent.description + " space(s) to rent"
        }
    }
}
