//
//  User.swift
//  HugoTwitter
//
//  Created by Hieu Nguyen on 2/17/16.
//  Copyright © 2016 Hugo Nguyen. All rights reserved.
//

import UIKit

var _currentUser: User?
let currentUserKey = "kCurrentUserKey"
let userDidLoginNotification = "userDidLoginNotification"
let userDidLogoutNotification = "userDidLogoutNotification"

class User: NSObject {
    let dictionary: NSDictionary
    let name: String?
    let screenname: String?
    let profileImageLowResUrl: String?
    let profileImageUrl: String?
    let tagline: String?
    
    init(dictionary: NSDictionary) {
        self.dictionary = dictionary
        var name = ""
        var screenname = ""
        var profileImageLowResUrl = ""
        var profileImageUrl = ""
        var tagline = ""
        if let nameStr = dictionary["name"] as? String {
            name = nameStr
        }
        if let screennameStr = dictionary["screen_name"] as? String {
            screenname = screennameStr
        }
        if let profileImageUrlStr = dictionary["profile_image_url"] as? String {
            profileImageLowResUrl = profileImageUrlStr
            profileImageUrl = profileImageUrlStr.stringByReplacingOccurrencesOfString("_normal", withString: "")
        }
        if let taglineStr = dictionary["description"] as? String {
            tagline = taglineStr
        }
        
        self.name = name
        self.screenname = screenname
        self.profileImageLowResUrl = profileImageLowResUrl
        self.profileImageUrl = profileImageUrl
        self.tagline = tagline
    }
    
    func logout() {
        User.currentUser = nil
        TwitterClient.sharedInstance.requestSerializer.removeAccessToken()
        
        NSNotificationCenter.defaultCenter().postNotificationName(userDidLogoutNotification, object: nil)
    }
    
    class var currentUser: User? {
        get {
            if _currentUser == nil {
                var data = NSUserDefaults.standardUserDefaults().objectForKey(currentUserKey) as? NSData
                if data != nil {
                    do {
                        var dictionary = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as! NSDictionary
                        _currentUser = User(dictionary: dictionary)
                    } catch {
        
                    }
                }
            }
            return _currentUser
        }
        set(user) {
            _currentUser = user
            
            if _currentUser != nil {
                do {
                    let data = try NSJSONSerialization.dataWithJSONObject(user!.dictionary, options: []) as NSData
                    NSUserDefaults.standardUserDefaults().setObject(data, forKey: currentUserKey)
                } catch {
                    print("JSON error")
                    NSUserDefaults.standardUserDefaults().setObject(nil, forKey: currentUserKey)
                }
            } else {
                NSUserDefaults.standardUserDefaults().setObject(nil, forKey: currentUserKey)
            }
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
}
