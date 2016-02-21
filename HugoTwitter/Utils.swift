//
//  Utils.swift
//  HugoTwitter
//
//  Created by Hieu Nguyen on 2/21/16.
//  Copyright © 2016 Hugo Nguyen. All rights reserved.
//

import UIKit

func loadLowResThenHighResImg(imageView: UIImageView, smallImageUrl: String, largeImageUrl: String, duration: NSTimeInterval) {
    let smallImageRequest = NSURLRequest(URL: NSURL(string: smallImageUrl)!)
    let largeImageRequest = NSURLRequest(URL: NSURL(string: largeImageUrl)!)
    
    imageView.setImageWithURLRequest(
        smallImageRequest,
        placeholderImage: nil,
        success: { (smallImageRequest, smallImageResponse, smallImage) -> Void in
            
            // smallImageResponse will be nil if the smallImage is already available
            // in cache (might want to do something smarter in that case).
            imageView.alpha = 0.0
            imageView.image = smallImage;
            
            UIView.animateWithDuration(duration, animations: { () -> Void in
                
                imageView.alpha = 1.0
                
                }, completion: { (sucess) -> Void in
                    
                    // The AFNetworking ImageView Category only allows one request to be sent at a time
                    // per ImageView. This code must be in the completion block.
                    imageView.setImageWithURLRequest(
                        largeImageRequest,
                        placeholderImage: smallImage,
                        success: { (largeImageRequest, largeImageResponse, largeImage) -> Void in
                            
                            imageView.image = largeImage;
                            
                        },
                        failure: { (request, response, error) -> Void in
                            // do something for the failure condition of the large image request
                            // possibly setting the ImageView's image to a default image
                    })
            })
        },
        failure: { (request, response, error) -> Void in
            // do something for the failure condition
            // possibly try to get the large image
    })
}