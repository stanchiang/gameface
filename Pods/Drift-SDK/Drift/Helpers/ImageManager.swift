//
//  ImageManager.swift
//  Drift
//
//  Created by Brian McDonald on 24/11/2016.
//  Copyright © 2016 Drift. All rights reserved.
//

import UIKit
import AlamofireImage
import Alamofire

class ImageManager {
    
    static let sharedManager = ImageManager()
    
    let photoCache = AutoPurgingImageCache(
        memoryCapacity: 100 * 1024 * 1024,
        preferredMemoryUsageAfterPurge: 60 * 1024 * 1024
    )

    
    func getImage(urlString: String, completion:@escaping (UIImage?) -> ()) {
        if let cachedImage = cachedImage(urlString: urlString){
            completion(cachedImage)
        }else{
            Alamofire.request(urlString).responseImage { response in
                if let image = response.result.value {
                    self.cacheImage(image: image, urlString: urlString)
                    return completion(image)
                }else{
                    return completion(nil)
                }
            }
        }
    }
    
    
    func cacheImage(image: Image, urlString: String) {
        if photoCache.image(withIdentifier: urlString) == nil{
            if image.size.width > 1000 && image.size.height > 1000{
                let size = image.size.applying(CGAffineTransform(scaleX: 0.4, y: 0.4))
                let hasAlpha = false
                let scale: CGFloat = 0.0 // Automatically use scale factor of main screen
                
                UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale)
                image.draw(in: CGRect(origin: CGPoint.zero, size: size))
                
                let newImage = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()                
                photoCache.add(newImage ?? image, withIdentifier: urlString)
                
            }else{
                photoCache.add(image, withIdentifier: urlString)
            }
        }
    }
    
    func cachedImage(urlString: String) -> Image? {
        return photoCache.image(withIdentifier: urlString)
    }
    
}
