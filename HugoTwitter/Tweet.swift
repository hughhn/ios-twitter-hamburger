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
    let id: String?
    let user: User?
    let text: String?
    let createdAtString: String?
    let createdAt: NSDate?
    let retweetName: String?
    let replyName: String?
    let favorited: Bool
    let retweetCount: Int
    let favCount: Int
    
    
    init(dictionary: NSDictionary) {
        self.dictionary = dictionary
        
        var id: String? = nil
        var user: User? = nil
        var text = ""
        var createdAtString = ""
        var createdAt: NSDate? = nil
        var retweetName: String? = nil
        var replyName: String? = nil
        var favorited = false
        var retweetCount = 0
        var favCount = 0
        
        if let idStr = dictionary["id_str"] as? String {
            id = idStr
        }
        
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
            }
            if let textStr = retweetedStatus["text"] as? String{
                text = textStr
            }
        }
        
        if let repliedTo = dictionary["in_reply_to_screen_name"] as? String {
            replyName = repliedTo
        }
        
        if let favoritedData = dictionary["favorited"] as? Bool {
            favorited = favoritedData
        }
        
        if let retweetCountData = dictionary["retweet_count"] as? Int {
            retweetCount = retweetCountData
        }
        if let favCountData = dictionary["favorite_count"] as? Int {
            favCount = favCountData
        }
        
        self.id = id
        self.user = user
        self.text = text
        self.createdAtString = createdAtString
        self.createdAt = createdAt
        self.retweetName = retweetName
        self.replyName = replyName
        self.favorited = favorited
        self.retweetCount = retweetCount
        self.favCount = favCount
    }
    
    class func tweetsWithArray(array: [NSDictionary]) -> [Tweet] {
        var tweets = [Tweet]()
        
        for dictionary in array {
            tweets.append(Tweet(dictionary: dictionary))
        }
        
        return tweets
    }
}
