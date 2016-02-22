//
//  TweetCell.swift
//  HugoTwitter
//
//  Created by Hieu Nguyen on 2/19/16.
//  Copyright © 2016 Hugo Nguyen. All rights reserved.
//

import UIKit

@objc protocol TweetCellDelegate {
    optional func favClicked(favTweet: Tweet?, completion: ((tweet: Tweet?, error: NSError?) -> ())?)
    optional func retweetClicked(retweetTweet: Tweet?, completion: ((tweet: Tweet?, error: NSError?) -> ())?)
    optional func composeClicked(replyToTweet: Tweet?)
}

private struct AssociatedKeys {
    static var btnStringTag = "btnStringTag"
}

extension UIButton {
    var stringTag: String? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.btnStringTag) as? String
        }
        
        set(value) {
            objc_setAssociatedObject(self,&AssociatedKeys.btnStringTag, value as NSString?, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

class TweetCell: UITableViewCell {

    @IBOutlet weak var repostIcon: UIImageView!
    @IBOutlet weak var repostLabel: UILabel!
    @IBOutlet weak var displayNameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var tweetLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var retweetedIcon: UIImageView!
    
    @IBOutlet weak var replyBtn: UIButton!
    @IBOutlet weak var retweetBtn: UIButton!
    @IBOutlet weak var favBtn: UIButton!
    @IBOutlet weak var retweetCountLabel: UILabel!
    @IBOutlet weak var favCountLabel: UILabel!
    
    @IBOutlet weak var profileImageTopMargin: NSLayoutConstraint!
    
    weak var delegate: TweetCellDelegate?
    
    var tweet: Tweet! {
        didSet {
            replyBtn.stringTag = tweet.id
            retweetBtn.stringTag = tweet.id
            favBtn.stringTag = tweet.id
            
            loadLowResThenHighResImg(profileImageView, smallImageUrl: tweet.user!.profileImageLowResUrl!, largeImageUrl: tweet.user!.profileImageUrl!, duration: 0)
            displayNameLabel.text = tweet.user!.name
            usernameLabel.text = "@\(tweet.user!.screenname!)"
            timestampLabel.text = DateManager.getFriendlyTime(tweet.createdAt!)
            
            do {
                let linkDetector = try NSDataDetector(types: NSTextCheckingType.Link.rawValue)
                let matches = linkDetector.matchesInString(tweet.text!, options: [], range: NSMakeRange(0, tweet.text!.length))
                
                var attributedString = NSMutableAttributedString(string: tweet.text!)
                
                let multipleAttributes = [
                    NSForegroundColorAttributeName: linkColor,
                    NSBackgroundColorAttributeName: UIColor.yellowColor(),
                    NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleDouble.rawValue ]
                
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
            
            refreshTweetData()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        self.layoutMargins = UIEdgeInsetsZero
        self.preservesSuperviewLayoutMargins = false
        
        profileImageView.layer.cornerRadius = 5
        profileImageView.clipsToBounds = true
        
        repostIcon.image = repostIcon.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        repostIcon.tintColor = customGrayColor
        
        retweetedIcon.image = retweetedIcon.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        retweetedIcon.tintColor = customGrayColor
        
        let replyImage = UIImage(named: "icon_reply")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        replyBtn.setImage(replyImage, forState: UIControlState.Normal)
        replyBtn.tintColor = customGrayColor
        
        retweetBtn.setImage(retweetImage, forState: UIControlState.Normal)
        favBtn.setImage(favImage, forState: UIControlState.Normal)
        
        replyBtn.addTarget(self, action: "onReply:", forControlEvents: UIControlEvents.TouchUpInside)
        retweetBtn.addTarget(self, action: "onRetweet:", forControlEvents: UIControlEvents.TouchUpInside)
        favBtn.addTarget(self, action: "onFav:", forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    func onReply(sender: UIButton) {
        print("replyButton tag: \(sender.stringTag!)")
        
        if sender.stringTag! == tweet.id! {
            delegate?.composeClicked?(self.tweet)
        }
    }
    
    func onRetweet(sender: UIButton) {
        print("retweetButton tag: \(sender.stringTag!)")
        
        if sender.stringTag! == tweet.id! {
            delegate?.retweetClicked?(self.tweet, completion: { (tweet, error) -> () in
                if error == nil && tweet!.id! == self.tweet.id! {
                    self.tweet = tweet
                    self.refreshTweetData()
                } else {
                    print("error toggle tweet retweet")
                }
            })
        }
    }
    
    func onFav(sender: UIButton) {
        print("favButton tag: \(sender.stringTag!)")
        
        if sender.stringTag! == tweet.id! {
            delegate?.favClicked?(self.tweet, completion: { (tweet, error) -> () in
                if error == nil && tweet!.id! == self.tweet.id! {
                    self.tweet = tweet
                    self.refreshTweetData()
                } else {
                    print("error toggle tweet fav")
                }
            })
        }
    }
    
    func refreshTweetData() {
        retweetCountLabel.text = "\(tweet.retweetCount)"
        favCountLabel.text = "\(tweet.favCount)"
        
        if tweet.retweeted {
            retweetBtn.tintColor = UIColor.greenColor()
        } else {
            retweetBtn.tintColor = customGrayColor
        }
        
        if tweet.favorited {
            favBtn.tintColor = UIColor.redColor()
        } else {
            favBtn.tintColor = customGrayColor
        }
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
