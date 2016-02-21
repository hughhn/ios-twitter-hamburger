//
//  TweetDetailedViewController.swift
//  HugoTwitter
//
//  Created by Hieu Nguyen on 2/20/16.
//  Copyright © 2016 Hugo Nguyen. All rights reserved.
//

import UIKit

@objc protocol TweetDetailedViewControllerDelegate {
    optional func favClicked(tweetDetailedViewController: TweetDetailedViewController, favTweet: Tweet?, completion: ((tweet: Tweet?, error: NSError?) -> ())?)
    optional func retweetClicked(tweetDetailedViewController: TweetDetailedViewController, retweetTweet: Tweet?, completion: ((tweet: Tweet?, error: NSError?) -> ())?)
    optional func composeClicked(tweetDetailedViewController: TweetDetailedViewController, replyToTweet: Tweet?)
}

class TweetDetailedViewController: UIViewController {

    weak var delegate: TweetDetailedViewControllerDelegate?
    
    @IBOutlet weak var repostIcon: UIImageView!
    @IBOutlet weak var repostLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var tweetLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var retweetCountLabel: UILabel!
    @IBOutlet weak var retweetCountSuffixLabel: UILabel!
    @IBOutlet weak var likeCountLabel: UILabel!
    @IBOutlet weak var likeCountSuffixLabel: UILabel!
    
    @IBOutlet weak var profileImageTopMargin: NSLayoutConstraint!
    
    @IBOutlet weak var replyBtn: UIButton!
    @IBOutlet weak var retweetBtn: UIButton!
    @IBOutlet weak var favBtn: UIButton!
    
    let retweetImage = UIImage(named: "icon_retweet")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)

    let favImage = UIImage(named: "icon_fav")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
    let favedImage = UIImage(named: "icon_faved")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
    
    var tweet: Tweet!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navigationController?.navigationBar.translucent = false;
        navigationItem.title = "Tweet"
        
        let negativeSpacer = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FixedSpace, target: nil, action: nil)
        negativeSpacer.width = -10
        
        let rightBtn = UIButton(type: .System)
        rightBtn.frame = CGRectMake(0, 0, 30, 30);
        let composeImage = UIImage(named: "icon_compose")
        rightBtn.setImage(composeImage!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate), forState: UIControlState.Normal)
        rightBtn.tintColor = twitterColor
        rightBtn.addTarget(self, action: "onCompose", forControlEvents: UIControlEvents.TouchUpInside)
        
        let rightBarBtn = UIBarButtonItem(customView: rightBtn)
        navigationItem.rightBarButtonItems = [negativeSpacer, rightBarBtn]
        
        
        profileImageView.layer.cornerRadius = 5
        profileImageView.clipsToBounds = true
        
        repostIcon.image = repostIcon.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        repostIcon.tintColor = customGrayColor
        
        let replyImage = UIImage(named: "icon_reply")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        replyBtn.setImage(replyImage, forState: UIControlState.Normal)
        replyBtn.tintColor = customGrayColor
        
        setupViews()
        print("Views loaded for Tweet: \(tweet.id!)")
    }
    
    func setupViews() {
        loadLowResThenHighResImg(profileImageView, smallImageUrl: tweet.user!.profileImageLowResUrl!, largeImageUrl: tweet.user!.profileImageUrl!, duration: 1.0)
        nameLabel.text = tweet.user!.name
        usernameLabel.text = "@\(tweet.user!.screenname!)"
        timeLabel.text = DateManager.detailedFormatter.stringFromDate(tweet.createdAt!)
        tweetLabel.text = tweet.text
        
        if tweet.retweetName != nil {
            repostLabel.text = "\(tweet.retweetName!) retweeted"
        } else {
            repostIcon.hidden = true
            repostLabel.hidden = true
            profileImageTopMargin.constant = 12
        }
        
        refreshTweetData()
    }
    
    func refreshTweetData() {
        retweetCountLabel.text = "\(tweet.retweetCount)"
        likeCountLabel.text = "\(tweet.favCount)"
        
        if tweet.retweeted {
            retweetBtn.setImage(retweetImage, forState: UIControlState.Normal)
            retweetBtn.tintColor = UIColor.greenColor()
        } else {
            retweetBtn.setImage(retweetImage, forState: UIControlState.Normal)
            retweetBtn.tintColor = customGrayColor
        }
        
        if tweet.favorited {
            favBtn.setImage(favedImage, forState: UIControlState.Normal)
            favBtn.tintColor = UIColor.redColor()
        } else {
            favBtn.setImage(favImage, forState: UIControlState.Normal)
            favBtn.tintColor = customGrayColor
        }
    }
    
    override func viewDidLayoutSubviews() {
        navigationController?.navigationBar.translucent = false;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func onCompose() {
        delegate?.composeClicked?(self, replyToTweet: nil)
    }

    @IBAction func onReply(sender: AnyObject) {
        delegate?.composeClicked?(self, replyToTweet: self.tweet)
    }
    
    @IBAction func onRetweet(sender: AnyObject) {
        // Fake fast response, then update later
        tweet.retweeted = !tweet.retweeted
        if tweet.retweeted {
            tweet.retweetCount++
        } else {
            tweet.retweetCount--
        }
        self.refreshTweetData()
        
        if tweet.retweeted {
            delegate?.retweetClicked?(self, retweetTweet: self.tweet, completion: { (tweet, error) -> () in
                if tweet != nil {
                    print("toggle Retweet")
                    self.tweet = tweet
                    self.refreshTweetData()
                }
            })
        } else {
            // un-retweet
        }
    }
    
    @IBAction func onFav(sender: AnyObject) {
        // Fake fast response, then update later
        tweet.favorited = !tweet.favorited
        if tweet.favorited {
            tweet.favCount++
        } else {
            tweet.favCount--
        }
        self.refreshTweetData()
        
        if tweet.favorited {
            delegate?.favClicked?(self, favTweet: self.tweet, completion: { (tweet, error) -> () in
                if tweet != nil {
                    print("toggle Fav")
                    self.tweet = tweet
                    self.refreshTweetData()
                }
            })
        } else {
            // un-fav
        }
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
