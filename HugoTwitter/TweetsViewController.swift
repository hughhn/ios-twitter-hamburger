//
//  TweetsViewController.swift
//  HugoTwitter
//
//  Created by Hieu Nguyen on 2/17/16.
//  Copyright © 2016 Hugo Nguyen. All rights reserved.
//

import UIKit

class TweetsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var tweets = [Tweet]()
    var homeParams: NSDictionary = ["include_rts": "1"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let titleView = UIView(frame: CGRectMake(0, 0, 30, 30))
        let titleImageView = UIImageView(image: UIImage(named: "icon_twitter"))
        titleImageView.frame = CGRectMake(0, 0, titleView.frame.width, titleView.frame.height)
        titleView.addSubview(titleImageView)
        navigationItem.titleView = titleView
        
        let leftBtn = UIButton(type: .System)
        leftBtn.frame = CGRectMake(0, 0, 30, 30);
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
        
        let negativeSpacer2 = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FixedSpace, target: nil, action: nil)
        negativeSpacer2.width = -10
        let rightBarBtn = UIBarButtonItem(customView: rightBtn)
        navigationItem.rightBarButtonItems = [negativeSpacer2, rightBarBtn]
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorInset = UIEdgeInsetsZero
        
        // Initialize a UIRefreshControl
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refreshControlAction:", forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)

        // Do any additional setup after loading the view.
        TwitterClient.sharedInstance.homeTimeline(homeParams) { (tweets, error) -> () in
            if let tweets = tweets {
                self.tweets = tweets
                // reload view
                self.tableView.reloadData()

            }
        }
    }
    
    // Makes a network request to get updated data
    // Updates the tableView with the new data
    // Hides the RefreshControl
    func refreshControlAction(refreshControl: UIRefreshControl) {
        TwitterClient.sharedInstance.homeTimeline(homeParams) { (tweets, error) -> () in
            refreshControl.endRefreshing()
            
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
    
    func onCompose() {
    
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
