//
//  TweetsViewController.swift
//  HugoTwitter
//
//  Created by Hieu Nguyen on 2/17/16.
//  Copyright © 2016 Hugo Nguyen. All rights reserved.
//

import UIKit

class TweetsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ComposeViewControllerDelegate, TweetCellDelegate, UIScrollViewDelegate, TweetDetailedViewControllerDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var isMoreDataLoading = false
    var loadingMoreView:InfiniteScrollActivityView?
    var tweets = [Tweet]()
    var defaultHomeParams: [String: String] = ["include_rts" : "1"]
    
    var isStandaloneController: Bool = true
    
    var tweetsEndpoint: ((params: NSDictionary?, completion: (tweets: [Tweet]?, error: NSError?) -> ()) -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationItem()
        setupTableView()

        tweetsEndpoint?(params: defaultHomeParams as NSDictionary) { (tweets, error) -> () in
            if let tweets = tweets {
                self.tweets = tweets
                // reload view
                self.tableView.reloadData()
                
            }
        }
    }
    
    func setupNavigationItem() {
        if isStandaloneController {
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
    }
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorInset = UIEdgeInsetsZero
        
        // Set up Infinite Scroll loading indicator
        let frame = CGRectMake(0, tableView.contentSize.height, tableView.bounds.size.width, InfiniteScrollActivityView.defaultHeight)
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.hidden = true
        tableView.addSubview(loadingMoreView!)
        
        // Initialize a UIRefreshControl
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refreshControlAction:", forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)
    }
    
    
    // Makes a network request to get updated data
    // Updates the tableView with the new data
    // Hides the RefreshControl
    func refreshControlAction(refreshControl: UIRefreshControl?) {
        var params = NSMutableDictionary()
        params.setValue("1", forKey: "include_rts")
        
//        var sinceId: String? = nil
//        if tweets.count > 0 {
//            sinceId = tweets[0].id
//        }
//        if sinceId != nil {
//            params.setValue(sinceId, forKey: "since_id")
//        }
        
        tweetsEndpoint?(params: params as NSDictionary) { (tweets, error) -> () in
            if refreshControl != nil {
                refreshControl!.endRefreshing()
            }
            
            if tweets != nil {
                //self.tweets.insertContentsOf(tweets!, at: 0)
                self.tweets = tweets!
                
                // reload view
                self.tableView.reloadData()
            }
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
        tweetDetailedVC.indexPath = indexPath
        tweetDetailedVC.delegate = self
        tweetDetailedVC.listener = self
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        
        navigationController?.pushViewController(tweetDetailedVC, animated: true)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TweetCell", forIndexPath: indexPath) as! TweetCell
        cell.tweet = tweets[indexPath.row]
        cell.delegate = self
        return cell
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func favClicked(favTweet: Tweet?, completion: ((tweet: Tweet?, error: NSError?) -> ())?) {
        onFav(favTweet, completion: completion)
    }
    
    func retweetClicked(retweetTweet: Tweet?, completion: ((tweet: Tweet?, error: NSError?) -> ())?) {
        onRetweet(retweetTweet, completion: completion)
    }
    
    func composeClicked(replyToTweet: Tweet?) {
        onCompose(replyToTweet)
    }
    
    func updateTweetCell(tweetDetailedViewController: TweetDetailedViewController, tweet: Tweet, indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! TweetCell
        cell.tweet.retweeted = tweet.retweeted
        cell.tweet.retweetCount = tweet.retweetCount
        cell.tweet.favorited = tweet.favorited
        cell.tweet.favCount = tweet.favCount
        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)
    }
    
    
    // reusable methods
    func onFav(favTweet: Tweet?, completion: ((tweet: Tweet?, error: NSError?) -> ())?) {
        if favTweet == nil {
            return
        }
        
        TwitterClient.sharedInstance.fav(favTweet!, params: nil) { (tweet, error) -> () in
            if completion != nil {
                completion!(tweet: tweet, error: error)
            }
        }
    }
    
    func onRetweet(retweetTweet: Tweet?, completion: ((tweet: Tweet?, error: NSError?) -> ())?) {
        if retweetTweet == nil {
            return
        }
        
        TwitterClient.sharedInstance.retweet(retweetTweet!, params: nil) { (tweet, error) -> () in
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
    
    func loadMoreTweets() {
        var params = NSMutableDictionary()
        var maxId: String? = nil
        
        if tweets.count > 0 {
            maxId = tweets[tweets.count - 1].id
        }
        if maxId != nil {
            let maxIdNum : Int64 = Int64(maxId!)!
            params.setValue(maxIdNum - 1, forKey: "max_id")
        }
        params.setValue("1", forKey: "include_rts")
        
        tweetsEndpoint?(params: params) { (var tweets, error) -> () in
            self.isMoreDataLoading = false
            self.loadingMoreView!.stopAnimating()
            if tweets != nil {
                if tweets![0].id! == self.tweets[self.tweets.count - 1].id! {
                    tweets!.removeAtIndex(0)
                }
                self.tweets.appendContentsOf(tweets!)
                
                // reload view
                self.tableView.reloadData()
            }
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if isMoreDataLoading {
            return
        }
        
        // Calculate the position of one screen length before the bottom of the results
        let scrollViewContentHeight = tableView.contentSize.height
        let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
        
        // When the user has scrolled past the threshold, start requesting
        if(scrollView.contentOffset.y > scrollOffsetThreshold && tableView.dragging) {
            isMoreDataLoading = true
            
            // Update position of loadingMoreView, and start loading indicator
            let frame = CGRectMake(0, tableView.contentSize.height, tableView.bounds.size.width, InfiniteScrollActivityView.defaultHeight)
            loadingMoreView?.frame = frame
            loadingMoreView!.startAnimating()
            
            loadMoreTweets()
        }
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
