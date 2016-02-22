//
//  TweetDetailedViewController.swift
//  HugoTwitter
//
//  Created by Hieu Nguyen on 2/20/16.
//  Copyright © 2016 Hugo Nguyen. All rights reserved.
//

import UIKit

class TweetDetailedViewController: UIViewController {

    weak var delegate: TweetCellDelegate?
    
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
        
        do {
            let linkDetector = try NSDataDetector(types: NSTextCheckingType.Link.rawValue)
            let matches = linkDetector.matchesInString(tweet.text!, options: [], range: NSMakeRange(0, tweet.text!.length))
            
            var attributedString = NSMutableAttributedString(string: tweet.text!)
            
            let multipleAttributes = [
                NSForegroundColorAttributeName: twitterColor ]
            
            for match in matches {
                attributedString.setAttributes(multipleAttributes, range: match.range)
            }
            
            tweetLabel.attributedText = attributedString
        } catch {
            tweetLabel.text = tweet.text
        }
        
        if tweet.retweetName != nil {
            repostIcon.image = retweetImage
            repostIcon.tintColor = customGrayColor
            repostLabel.text = "\(tweet.retweetName!) retweeted"
        } else if tweet.replyName != nil {
            repostIcon.image = replyImage
            repostIcon.tintColor = customGrayColor
            repostLabel.text = "In reply to \(tweet.replyName!)"
        } else {
            repostIcon.hidden = true
            repostLabel.hidden = true
            profileImageTopMargin.constant = 12
        }
        
        retweetBtn.setImage(retweetImage, forState: UIControlState.Normal)
        favBtn.setImage(favImage, forState: UIControlState.Normal)
        
        refreshTweetData()
    }
    
    func refreshTweetData() {
        retweetCountLabel.text = "\(tweet.retweetCount)"
        likeCountLabel.text = "\(tweet.favCount)"
        
        if tweet.retweeted {
            retweetBtn.tintColor = retweetColor
        } else {
            retweetBtn.tintColor = customGrayColor
        }
        
        if tweet.favorited {
            favBtn.tintColor = favColor
        } else {
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
        delegate?.composeClicked?(nil)
    }

    @IBAction func onReply(sender: AnyObject) {
        delegate?.composeClicked?(self.tweet)
    }
    
    @IBAction func onRetweet(sender: AnyObject) {
        delegate?.retweetClicked?(self.tweet, completion: { (tweet, error) -> () in
            if error == nil {
                self.tweet = tweet
                self.refreshTweetData()
            } else {
                print("error toggle tweet retweet")
            }
        })
    }
    
    @IBAction func onFav(sender: AnyObject) {
        delegate?.favClicked?(self.tweet, completion: { (tweet, error) -> () in
            if error == nil {
                self.tweet = tweet
                self.refreshTweetData()
            } else {
                print("error toggle tweet fav")
            }
        })
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
