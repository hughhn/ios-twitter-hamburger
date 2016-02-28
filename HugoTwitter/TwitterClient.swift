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
    
    func fav(tweet: Tweet!, params: NSDictionary?, completion: (tweet: Tweet?, error: NSError?) -> ()) {
        // Toggle fav
        tweet.favorited = !tweet.favorited
        
        var myParams = (params == nil) ? NSMutableDictionary() : NSMutableDictionary(dictionary: params!)
        myParams.setValue(tweet.id! as! String, forKey: "id")
        
        var favUrl = "1.1/favorites/create.json"
        if !tweet.favorited {
            // un-fav
            tweet.favCount--
            favUrl = "1.1/favorites/destroy.json"
        } else {
            tweet.favCount++
        }
        
        POST(favUrl, parameters: myParams, success:
            { (operation: NSURLSessionDataTask, response: AnyObject?) -> Void in
                
                completion(tweet: tweet, error: nil)
                
            }, failure: { (task: NSURLSessionDataTask?, error: NSError) -> Void in
                print("favorite API error")
                print(error.debugDescription)
                completion(tweet: nil, error: error)
        })
    }
    
    func retweet(tweet: Tweet!, params: NSDictionary?, completion: (tweet: Tweet?, error: NSError?) -> ()) {
        // Toggle retweet
        tweet.retweeted = !tweet.retweeted
        if tweet.retweeted {
            tweet.retweetCount++
        } else {
            tweet.retweetCount--
        }
        
        if tweet.retweeted {
            let retweetUrl = "1.1/statuses/retweet/\(tweet.id!).json"
            POST(retweetUrl, parameters: params, success:
                { (operation: NSURLSessionDataTask, response: AnyObject?) -> Void in
                    
                    completion(tweet: tweet, error: nil)
                    
                }, failure: { (task: NSURLSessionDataTask?, error: NSError) -> Void in
                    print("retweet API error")
                    print(error.debugDescription)
                    completion(tweet: nil, error: error)
            })
        } else {
            unRetweet(tweet, params: params, completion: completion)
        }
    }
    
    func unRetweet(tweet: Tweet!, params: NSDictionary?, completion: (tweet: Tweet?, error: NSError?) -> ()) {
        if tweet.retweetOriginalId == nil {
            return
        }
        
        print("retweet original Id = \(tweet.retweetOriginalId!)")
        var myParams = NSMutableDictionary()
        myParams.setValue(tweet.retweetOriginalId!, forKey: "id")
        myParams.setValue("true", forKey: "include_my_retweet")
        
        GET("1.1/statuses/show.json", parameters: myParams, success:
            { (operation: NSURLSessionDataTask, response: AnyObject?) -> Void in
                
                if let retweet = response as? NSDictionary {
                    if let currentUserRetweet = retweet["current_user_retweet"] as? NSDictionary {
                        if let retweetToDeleteID = currentUserRetweet["id_str"] as? String {
                            let destroyUrl = "1.1/statuses/destroy/\(retweetToDeleteID).json"
                            self.POST(destroyUrl, parameters: nil, success:
                                { (operation: NSURLSessionDataTask, response: AnyObject?) -> Void in
                                    
                                    completion(tweet: tweet, error: nil)
                                    
                                }, failure: { (task: NSURLSessionDataTask?, error: NSError) -> Void in
                                    print("un-retweet API error")
                                    print(error.debugDescription)
                                    completion(tweet: nil, error: error)
                            })
                            
                        }
                    }
                }
                
            }, failure: { (task: NSURLSessionDataTask?, error: NSError) -> Void in
                print("could not retrieve original retweet")
                print(error.debugDescription)
                completion(tweet: nil, error: error)
        })
    }
    
    func updateStatus(params: NSDictionary?, completion: (tweet: Tweet?, error: NSError?) -> ()) {
        POST("1.1/statuses/update.json", parameters: params, success:
            { (operation: NSURLSessionDataTask, response: AnyObject?) -> Void in
                
                let tweet = Tweet(dictionary: response as! NSDictionary)
                completion(tweet: tweet, error: nil)
                
            }, failure: { (task: NSURLSessionDataTask?, error: NSError) -> Void in
                print("update.json error")
                print(error.debugDescription)
                completion(tweet: nil, error: error)
        })
    }
    
    let homelineCacheKey = "homelineCacheKey"
    func homeTimeline(params: NSDictionary?, completion: (tweets: [Tweet]?, error: NSError?) -> ()) {
        GET("1.1/statuses/home_timeline.json", parameters: params, success:
            { (operation: NSURLSessionDataTask, response: AnyObject?) -> Void in
            
            do {
                let data = try NSJSONSerialization.dataWithJSONObject(response!, options: []) as NSData
                NSUserDefaults.standardUserDefaults().setObject(data, forKey: self.homelineCacheKey)
            } catch {}
            
            var tweets = Tweet.tweetsWithArray(response as! [NSDictionary])
            completion(tweets: tweets, error: nil)
        }, failure: { (task: NSURLSessionDataTask?, apiError: NSError) -> Void in
            print("home_timeline error")
            print(apiError.debugDescription)
            
            
            var data = NSUserDefaults.standardUserDefaults().objectForKey(self.homelineCacheKey) as? NSData
            if data != nil {
                do {
                    var cache = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as! [NSDictionary]
                    var tweets = Tweet.tweetsWithArray(cache)
                    completion(tweets: tweets, error: nil)
                } catch {
                    completion(tweets: nil, error: apiError)
                }
            }
            
            //completion(tweets: nil, error: error)
        })
    }
    
    func mentionsTimeline(params: NSDictionary?, completion: (tweets: [Tweet]?, error: NSError?) -> ()) {
        GET("1.1/statuses/mentions_timeline.json", parameters: params, success:
            { (operation: NSURLSessionDataTask, response: AnyObject?) -> Void in
                var tweets = Tweet.tweetsWithArray(response as! [NSDictionary])
                completion(tweets: tweets, error: nil)
            }, failure: { (task: NSURLSessionDataTask?, apiError: NSError) -> Void in
                print("mentions_timeline error")
                print(apiError.debugDescription)
                completion(tweets: nil, error: apiError)
        })
    }
    
    func userProfile(screenName: String?, userId: String?, params: NSDictionary?, completion: (user: User?, error: NSError?) -> ()) {
        var myParams = (params == nil) ? NSMutableDictionary() : NSMutableDictionary(dictionary: params!)
        if screenName != nil {
            myParams.setValue(screenName!, forKey: "screen_name")
        } else if userId != nil {
            myParams.setValue(userId!, forKey: "user_id")
        } else {
            completion(user: nil, error: NSError(domain: "need screen_name or user_id", code: 123, userInfo: nil))
            return
        }
        
        GET("1.1/users/show.json", parameters: myParams, success:
            { (operation: NSURLSessionDataTask, response: AnyObject?) -> Void in
                var user = User(dictionary: response as! NSDictionary)
                completion(user: user, error: nil)
            }, failure: { (task: NSURLSessionDataTask?, apiError: NSError) -> Void in
                print("users/show error")
                print(apiError.debugDescription)
                completion(user: nil, error: apiError)
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