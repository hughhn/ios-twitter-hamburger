//
//  Utils.swift
//  HugoTwitter
//
//  Created by Hieu Nguyen on 2/21/16.
//  Copyright © 2016 Hugo Nguyen. All rights reserved.
//

import UIKit

extension Int {
    func prettify() -> String {
        func floatToString(val: Float) -> String {
            var ret: NSString = NSString(format: "%.1f", val)
            
            let c = ret.characterAtIndex(ret.length - 1)
            
            if c == 46 {
                ret = ret.substringToIndex(ret.length - 1)
            }
            
            return ret as String
        }
        
        var abbrevNum = ""
        var num: Float = Float(self)
        
        if num >= 1000 {
            var abbrev = ["K","M","B"]
            
            for var i = abbrev.count-1; i >= 0; i-- {
                let sizeInt = pow(Double(10), Double((i+1)*3))
                let size = Float(sizeInt)
                
                if size <= num {
                    num = num/size
                    var numStr: String = floatToString(num)
                    if numStr.hasSuffix(".0") {
                        let startIndex = numStr.startIndex.advancedBy(0)
                        let endIndex = numStr.endIndex.advancedBy(-2)
                        let range = startIndex..<endIndex
                        numStr = numStr.substringWithRange( range )
                    }
                    
                    let suffix = abbrev[i]
                    abbrevNum = numStr+suffix
                }
            }
        } else {
            abbrevNum = "\(num)"
            let startIndex = abbrevNum.startIndex.advancedBy(0)
            let endIndex = abbrevNum.endIndex.advancedBy(-2)
            let range = startIndex..<endIndex
            abbrevNum = abbrevNum.substringWithRange( range )
        }
        
        return abbrevNum
    }
}

func floatToString(val: Float) -> NSString {
    var ret = NSString(format: "%.1f", val)
    var c = ret.characterAtIndex(ret.length - 1)
    
    while c == 48 {
        ret = ret.substringToIndex(ret.length - 1)
        c = ret.characterAtIndex(ret.length - 1)
        
        
        if (c == 46) {
            ret = ret.substringToIndex(ret.length - 1)
        }
    }
    return ret
}

func fadeInImg(imageView: UIImageView, imageUrl: String, duration: NSTimeInterval) {
    let imageRequest = NSURLRequest(URL: NSURL(string: imageUrl)!)
    
    imageView.setImageWithURLRequest(
        imageRequest,
        placeholderImage: nil,
        success: { (imageRequest, imageResponse, image) -> Void in
            
            // imageResponse will be nil if the image is cached
            if imageResponse != nil {
                //print("Image was NOT cached, fade in image")
                imageView.alpha = 0.0
                imageView.image = image
                UIView.animateWithDuration(duration, animations: { () -> Void in
                    imageView.alpha = 1.0
                })
            } else {
                //print("Image was cached so just update the image")
                imageView.image = image
            }
        },
        failure: { (imageRequest, imageResponse, error) -> Void in
            // do something for the failure condition
    })
}

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


func loadLowResThenHighResImg(button: UIButton, smallImageUrl: String, largeImageUrl: String, duration: NSTimeInterval) {
    let smallImageRequest = NSURLRequest(URL: NSURL(string: smallImageUrl)!)
    let largeImageRequest = NSURLRequest(URL: NSURL(string: largeImageUrl)!)
    
    button.setImageForState(UIControlState.Normal, withURLRequest: smallImageRequest, placeholderImage: nil, success: { (smallImageRequest, smallImageResponse, smallImage) -> Void in
        
        button.imageView?.alpha = 0.0
        button.imageView?.image = smallImage
        
        UIView.animateWithDuration(duration, animations: { () -> Void in
            
            button.imageView?.alpha = 1.0
            
            }, completion: { (sucess) -> Void in
                
                // The AFNetworking ImageView Category only allows one request to be sent at a time
                // per ImageView. This code must be in the completion block.
                button.setImageForState(UIControlState.Normal, withURLRequest: largeImageRequest, placeholderImage: nil, success: { (largeImageRequest, largeImageResponse, largeImage) -> Void in
                        
                        button.imageView?.image = largeImage;
                        
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