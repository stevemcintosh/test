//
//  ModelsForVariousLogTypes.swift
//  test
//
//  Created by Stephen McIntosh on 4/03/2016.
//  Copyright © 2016 Stephen McIntosh. All rights reserved.
//

import UIKit

    // MARK: - BaseLog
public class BaseLog: NSObject, NSCoding {
    public let date: NSDate
    
    public init(date: NSDate) {
        self.date = date
        super.init()
    }
    
    // MARK: - NSCoding
    
    public required init?(coder aDecoder: NSCoder) {
        self.date = aDecoder.decodeObjectForKey("date") as! NSDate
        super.init()
    }
    
    public func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.date, forKey: "date")
    }
    
}

    // MARK: - TextLog
public class TextLog: BaseLog {
    
    public let text: String
    
    public required init(text: String, date: NSDate) {
        self.text = text
        super.init(date: date)
    }
    
    // MARK: NSCoding
    
    public required init?(coder aDecoder: NSCoder) {
        self.text = aDecoder.decodeObjectForKey("text") as! String
        super.init(coder: aDecoder)
    }
    
    public override func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.text, forKey: "text")
        super.encodeWithCoder(aCoder)
    }
    
}

    // MARK: - ImageLog
public class ImageLog: BaseLog {
    
    public let image: UIImage
    
    public required init(image: UIImage, date: NSDate) {
        self.image = image
        super.init(date: date)
    }
    
    // MARK: - NSCoding
    
    public required init?(coder aDecoder: NSCoder) {
        let data = aDecoder.decodeObjectForKey("image") as! NSData
        let image = UIImage(data: data)!
        self.image = image
        super.init(coder: aDecoder)
    }
    
    public override func encodeWithCoder(aCoder: NSCoder) {
        let data = UIImageJPEGRepresentation(self.image, 1.0)
        aCoder.encodeObject(data, forKey: "image")
        super.encodeWithCoder(aCoder)
    }
    
}

    // MARK: - VideoLog
public class VideoLog: BaseLog {
    
    public let URL: NSURL
    public let previewImage: UIImage
    
    public required init(URL: NSURL, previewImage: UIImage, date: NSDate) {
        self.URL = URL
        self.previewImage = previewImage
        super.init(date: date)
    }
    
    // MARK: - NSCoding
    
    public required init?(coder aDecoder: NSCoder) {
        self.URL = aDecoder.decodeObjectForKey("URL") as! NSURL
        let data = aDecoder.decodeObjectForKey("previewImage") as! NSData
        let image = UIImage(data: data)!
        self.previewImage = image
        super.init(coder: aDecoder)
    }
    
    public override func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.URL, forKey: "URL")
        let data = UIImageJPEGRepresentation(self.previewImage, 1.0)
        aCoder.encodeObject(data, forKey: "previewImage")
        super.encodeWithCoder(aCoder)
    }
    
}
