//
//  Tweet.swift
//  HugoTwitter
//
//  Created by Hieu Nguyen on 2/17/16.
//  Copyright © 2016 Hugo Nguyen. All rights reserved.
//

import UIKit

class Tweet: NSObject {
    var dictionary: NSDictionary
    var user: User?
    var text: String?
    var createdAtString: String?
    var createdAt: NSDate?
    
    init(dictionary: NSDictionary) {
        self.dictionary = dictionary
        
        var user: User? = nil
        var text = ""
        var createdAtString = ""
        var createdAt: NSDate? = nil
        
        if let userDict = dictionary["user"] as? NSDictionary {
            user = User(dictionary: userDict)
        }
        if let textStr = dictionary["text"] as? String {
            text = textStr
        }
        if let createdAtStr = dictionary["created_at"] as? String {
            createdAtString = createdAtStr
            var dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "EEE MMM d HH:mm:ss Z y"
            createdAt = dateFormatter.dateFromString(createdAtString)
        }
        
        self.user = user
        self.text = text
        self.createdAtString = createdAtString
        self.createdAt = createdAt
    }
    
    class func tweetsWithArray(array: [NSDictionary]) -> [Tweet] {
        var tweets = [Tweet]()
        
        for dictionary in array {
            tweets.append(Tweet(dictionary: dictionary))
        }
        
        return tweets
    }
}
