//
//  Tweet.swift
//  HugoTwitter
//
//  Created by Hieu Nguyen on 2/17/16.
//  Copyright © 2016 Hugo Nguyen. All rights reserved.
//

import UIKit

class Tweet: NSObject {
    let dictionary: NSDictionary
    let user: User?
    let text: String?
    let createdAtString: String?
    let createdAt: NSDate?
    let isRetweet: Bool
    let retweetName: String?
    
    init(dictionary: NSDictionary) {
        self.dictionary = dictionary
        
        var user: User? = nil
        var text = ""
        var createdAtString = ""
        var createdAt: NSDate? = nil
        var isRetweet = false
        var retweetName = ""
        
        if let userDict = dictionary["user"] as? NSDictionary {
            user = User(dictionary: userDict)
        }
        if let textStr = dictionary["text"] as? String {
            text = textStr
        }
        if let createdAtStr = dictionary["created_at"] as? String {
            createdAtString = createdAtStr
            createdAt = DateManager.defaultFormatter.dateFromString(createdAtString)
        }
        
        if let retweetedStatus = dictionary["retweeted_status"] as? NSDictionary {
            if let retweetUserDict = retweetedStatus["user"] as? NSDictionary {
                let retweetUser = User(dictionary: retweetUserDict)
                retweetName = user!.name!
                user = retweetUser
                isRetweet = true
            }
            if let textStr = retweetedStatus["text"] as? String{
                text = textStr
            }
        }
        
        self.user = user
        self.text = text
        self.createdAtString = createdAtString
        self.createdAt = createdAt
        self.isRetweet = isRetweet
        self.retweetName = retweetName
    }
    
    class func tweetsWithArray(array: [NSDictionary]) -> [Tweet] {
        var tweets = [Tweet]()
        
        for dictionary in array {
            tweets.append(Tweet(dictionary: dictionary))
        }
        
        return tweets
    }
}
