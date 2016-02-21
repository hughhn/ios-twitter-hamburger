//
//  TweetsViewController.swift
//  HugoTwitter
//
//  Created by Hieu Nguyen on 2/17/16.
//  Copyright © 2016 Hugo Nguyen. All rights reserved.
//

import UIKit

class TweetsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ComposeViewControllerDelegate, TweetDetailedViewControllerDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var tweets = [Tweet]()
    var homeParams: [String: String] = ["include_rts": "1"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationItem()
        setupTableView()

        TwitterClient.sharedInstance.homeTimeline(homeParams as! NSDictionary) { (tweets, error) -> () in
            if let tweets = tweets {
                self.tweets = tweets
                // reload view
                self.tableView.reloadData()

            }
        }
    }
    
    func setupNavigationItem() {
        let titleView = UIView(frame: CGRectMake(0, 0, 30, 30))
        let titleImageView = UIImageView(image: UIImage(named: "icon_twitter"))
        titleImageView.image = titleImageView.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        titleImageView.tintColor = twitterColor
        titleImageView.frame = CGRectMake(0, 0, titleView.frame.width, titleView.frame.height)
        titleView.addSubview(titleImageView)
        navigationItem.titleView = titleView
        
        let leftBtn = UIButton(type: .System)
        leftBtn.frame = CGRectMake(0, 0, 25, 23);
        let logoutImage = UIImage(named: "icon_logout")
        leftBtn.setImage(logoutImage!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate), forState: UIControlState.Normal)
        leftBtn.tintColor = twitterColor
        leftBtn.addTarget(self, action: "onLogout", forControlEvents: UIControlEvents.TouchUpInside)
        
        let negativeSpacer = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FixedSpace, target: nil, action: nil)
        negativeSpacer.width = -10
        let leftBarBtn = UIBarButtonItem(customView: leftBtn)
        navigationItem.leftBarButtonItems = [negativeSpacer, leftBarBtn]
        
        let rightBtn = UIButton(type: .System)
        rightBtn.frame = CGRectMake(0, 0, 30, 30);
        let composeImage = UIImage(named: "icon_compose")
        rightBtn.setImage(composeImage!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate), forState: UIControlState.Normal)
        rightBtn.tintColor = twitterColor
        rightBtn.addTarget(self, action: "onCompose", forControlEvents: UIControlEvents.TouchUpInside)
        
        let rightBarBtn = UIBarButtonItem(customView: rightBtn)
        navigationItem.rightBarButtonItems = [negativeSpacer, rightBarBtn]
    }
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorInset = UIEdgeInsetsZero
        
        // Initialize a UIRefreshControl
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refreshControlAction:", forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)
    }
    
    
    // Makes a network request to get updated data
    // Updates the tableView with the new data
    // Hides the RefreshControl
    func refreshControlAction(refreshControl: UIRefreshControl?) {
        TwitterClient.sharedInstance.homeTimeline(homeParams as! NSDictionary) { (tweets, error) -> () in
            if refreshControl != nil {
                refreshControl!.endRefreshing()
            }
            
            self.tweets = tweets!
            
            // reload view
            self.tableView.reloadData()
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let tweetDetailedVC = TweetDetailedViewController()
        let tweet = tweets[indexPath.row]
        tweetDetailedVC.tweet = tweet
        tweetDetailedVC.delegate = self
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        
        navigationController?.pushViewController(tweetDetailedVC, animated: true)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TweetCell", forIndexPath: indexPath) as! TweetCell
        cell.tweet = tweets[indexPath.row]
        return cell
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func favClicked(tweetDetailedViewController: TweetDetailedViewController, favTweet: Tweet?, completion: ((tweet: Tweet?, error: NSError?) -> ())?) {
        onFav(favTweet, completion: completion)
    }
    
    func retweetClicked(tweetDetailedViewController: TweetDetailedViewController, retweetTweet: Tweet?, completion: ((tweet: Tweet?, error: NSError?) -> ())?) {
        onRetweet(retweetTweet, completion: completion)
    }
    
    func composeClicked(tweetDetailedViewController: TweetDetailedViewController, replyToTweet: Tweet?) {
        onCompose(replyToTweet)
    }
    
    // reusable methods
    func onFav(favTweet: Tweet?, completion: ((tweet: Tweet?, error: NSError?) -> ())?) {
        if favTweet == nil {
            return
        }
        
        let params: NSDictionary = ["id": favTweet!.id!]
        print("fav tweet ID = \(favTweet!.id!)")
        TwitterClient.sharedInstance.fav(params) { (tweet, error) -> () in
            if tweet != nil {
                self.refreshControlAction(nil)
            }
            if completion != nil {
                completion!(tweet: tweet, error: error)
            }
        }
    }
    
    func onRetweet(retweetTweet: Tweet?, completion: ((tweet: Tweet?, error: NSError?) -> ())?) {
        if retweetTweet == nil {
            return
        }
        
        let params: NSDictionary = ["id": retweetTweet!.id!]
        print("retweet tweet ID = \(retweetTweet!.id!)")
        TwitterClient.sharedInstance.retweet(params) { (tweet, error) -> () in
            if tweet != nil {
                self.refreshControlAction(nil)
            }
            if completion != nil {
                completion!(tweet: tweet, error: error)
            }
        }
    }
    
    func onTweetSend(composeViewController: ComposeViewController, tweetStatus: String!, replyToTweet: Tweet?) {
        dismissViewControllerAnimated(true, completion: nil)
        
        var params = ["status": tweetStatus]
        if replyToTweet != nil {
            params["in_reply_to_status_id"] = replyToTweet!.id!
        }
        
        TwitterClient.sharedInstance.updateStatus(params as! NSDictionary) { (tweet, error) -> () in
            if tweet != nil {
                self.refreshControlAction(nil)
            }
        }
    }
    
    func onCompose() {
        onCompose(nil)
    }
    
    func onCompose(replyToTweet: Tweet?) {
        let composeVC = ComposeViewController()
        composeVC.delegate = self
        composeVC.user = User.currentUser
        composeVC.replyToTweet = replyToTweet
        navigationController?.presentViewController(composeVC, animated: true, completion: nil)
    }
    
    func onComposeViewClosed(composeViewController: ComposeViewController, tweetStatus: String!) {
        dismissViewControllerAnimated(true, completion: nil)
        
        // save in progress Tweet
    }
    
    func onLogout() {
        User.currentUser?.logout()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
