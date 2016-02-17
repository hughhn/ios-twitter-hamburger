//
//  TwitterClient.swift
//  HugoTwitter
//
//  Created by Hieu Nguyen on 2/17/16.
//  Copyright © 2016 Hugo Nguyen. All rights reserved.
//

import UIKit
import BDBOAuth1Manager

let twitterConsumerKey = "vOozEpACtiMspXITWoUEXTw67"
let twitterConsumerSecret = "AJSYVKaiGTKZVvt0RRpcgRnt2iLECD0SIOjqWXs2hR6xB6dm8h"
let twitterBaseURL = NSURL(string: "https://api.twitter.com")

class TwitterClient: BDBOAuth1SessionManager {
    
    var loginCompletion: ((user: User?, error: NSError?) -> ())?
    
    class var sharedInstance: TwitterClient {
        struct Static {
            static let instance = TwitterClient(baseURL: twitterBaseURL,
                consumerKey: twitterConsumerKey,
                consumerSecret: twitterConsumerSecret)
        }
        
        return Static.instance
    }
    
    func homeTimeline(params: NSDictionary?,completion: (tweets: [Tweet]?, error: NSError?) -> ()) {
        GET("1.1/statuses/home_timeline.json", parameters: params, success:
            { (operation: NSURLSessionDataTask, response: AnyObject?) -> Void in
            
            var tweets = Tweet.tweetsWithArray(response as! [NSDictionary])
            //                for tweet in tweets {
            //                    print("text: \(tweet.text); created: \(tweet.createAt)")
            //                }
            
            completion(tweets: tweets, error: nil)
        }, failure: { (task: NSURLSessionDataTask?, error: NSError) -> Void in
            print("home_timeline error")
            completion(tweets: nil, error: error)
        })
    }
    
    func loginWithCompletion(completion: (user: User?, error: NSError?) -> ()) {
        loginCompletion = completion
        
        requestSerializer.removeAccessToken()
        fetchRequestTokenWithPath("oauth/request_token", method: "GET", callbackURL: NSURL(string: "cptwitterdemo://oauth"), scope: nil, success: { (requestToken: BDBOAuth1Credential!) -> Void in
            var authURL = NSURL(string: "https://api.twitter.com/oauth/authorize?oauth_token=\(requestToken.token)")
            UIApplication.sharedApplication().openURL(authURL!)
            }) { (error: NSError!) -> Void in
                print("requestToken error")
                self.loginCompletion?(user: nil, error: error)
        }
    }
    
    func openURL(url: NSURL) {
        fetchAccessTokenWithPath("oauth/access_token", method: "POST", requestToken: BDBOAuth1Credential(queryString: url.query), success: { (accessToken: BDBOAuth1Credential!) -> Void in
            TwitterClient.sharedInstance.requestSerializer.saveAccessToken(accessToken)
            
            TwitterClient.sharedInstance.GET("1.1/account/verify_credentials.json", parameters: nil, success: { (operation: NSURLSessionDataTask, response: AnyObject?) -> Void in
                var user = User(dictionary: response as! NSDictionary)
                User.currentUser = user
                self.loginCompletion?(user: user, error: nil)
                }, failure: { (task: NSURLSessionDataTask?, error: NSError) -> Void in
                    print("verify_credentials error")
                    self.loginCompletion?(user: nil, error: error)
            })
            
            }) { (error: NSError!) -> Void in
                print("accessToken error")
                self.loginCompletion?(user: nil, error: error)
        }
    }
}