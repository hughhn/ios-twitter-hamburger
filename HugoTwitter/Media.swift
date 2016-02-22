//
//  Media.swift
//  HugoTwitter
//
//  Created by Hieu Nguyen on 2/21/16.
//  Copyright © 2016 Hugo Nguyen. All rights reserved.
//

import UIKit

class Media: NSObject {
    let dictionary: NSDictionary
    
    let mediaUrl: String?
    let type = "photo"
    
    init(dictionary: NSDictionary) {
        self.dictionary = dictionary
        
        var mediaUrl: String? = nil
        if let mediaUrlStr = dictionary["media_url"] as? String {
            mediaUrl = mediaUrlStr
        }
        
        self.mediaUrl = mediaUrl
        //print(self.mediaUrl!)
    }
}
