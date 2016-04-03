import Foundation
import UIKit

struct TileImageResult {
    // MARK: Properties
    
    let image: UIImage
    
    // MARK: Initialization
    init?(image: UIImage?) {
        guard let theImage = image else { return nil }
        
        self.image = theImage
    }
}

class DownloadTileImageOperation: GroupOperation {
    // MARK: Properties

    let imageURL: NSURL
    let completionHandler: (TileImageResult?) -> Void
    
    // MARK: Initialization
    
    /// - parameter cacheFile: The file `NSURL` to which the tile feed will be downloaded.
    init(imageURL: NSURL, completionHandler: (TileImageResult?) -> Void) {
        self.imageURL = imageURL
        self.completionHandler = completionHandler
        
        super.init(operations:[])
        name = "Download Tile Image"
        
        let request = NSURLRequest(URL: imageURL)
        let session = NSURLSession.sharedSession()
        let dataTask = session.dataTaskWithRequest(request) {
            (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            if let parsedImageResult = TileImageResult(image: UIImage(data: data!)) {
                self.completionHandler(parsedImageResult)
            }
        }
        dataTask.resume()
    }
    
    func downloadFinished(url: NSURL?, response: NSHTTPURLResponse?, error: NSError?) {
        
        if let localURL = url {
            do {
                print("url: \(localURL.absoluteString)")
                let request = NSURLRequest(URL: localURL)
                let session = NSURLSession.sharedSession()
                let dataTask = session.dataTaskWithRequest(request) {
                    (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
                    dispatch_async(dispatch_get_main_queue()) {
                        if let parsedImageResult = TileImageResult(image: UIImage(data: data!)) {
                            self.completionHandler(parsedImageResult)
                        }
                    }
                }
                dataTask.resume()
            }
        }
        else if let error = error {
//            aggregateError(error)
        }
        else {
            // Do nothing, and the operation will automatically finish.
        }
    }
}
