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
    @IBOutlet weak var profileImageButton: UIButton!
    
    @IBOutlet weak var replyBtn: UIButton!
    @IBOutlet weak var retweetBtn: UIButton!
    @IBOutlet weak var favBtn: UIButton!
    @IBOutlet weak var retweetCountLabel: UILabel!
    @IBOutlet weak var favCountLabel: UILabel!
    
    @IBOutlet weak var mediaImageView: UIImageView!
    @IBOutlet weak var mediaImageHeight: NSLayoutConstraint!
    
    @IBOutlet weak var mediaImageBottomSpace: NSLayoutConstraint!
    @IBOutlet weak var profileImageButtonTopMargin: NSLayoutConstraint!
    
    weak var delegate: TweetCellDelegate?
    
    var tweet: Tweet! {
        didSet {
            replyBtn.stringTag = tweet.id
            retweetBtn.stringTag = tweet.id
            favBtn.stringTag = tweet.id
            
//            loadLowResThenHighResImg(profileImageButton, smallImageUrl: tweet.user!.profileImageLowResUrl!, largeImageUrl: tweet.user!.profileImageUrl!, duration: 0)
            profileImageButton.setBackgroundImageForState(UIControlState.Normal, withURL: NSURL(string: tweet.user!.profileImageUrl!)!)
            displayNameLabel.text = tweet.user!.name!
            usernameLabel.text = "@\(tweet.user!.screenname!)"
            timestampLabel.text = DateManager.getFriendlyTime(tweet.createdAt!)
            tweetLabel.text = tweet.text
            
            if tweet.retweetName != nil {
                repostIcon.hidden = false
                repostLabel.hidden = false
                profileImageButtonTopMargin.constant = 30
                repostIcon.image = retweetImage
                repostLabel.text = "\(tweet.retweetName!) retweeted"
            } else if tweet.replyName != nil {
                repostIcon.hidden = false
                repostLabel.hidden = false
                profileImageButtonTopMargin.constant = 30
                repostIcon.image = replyImage
                repostLabel.text = "In reply to \(tweet.replyName!)"
            } else {
                repostIcon.hidden = true
                repostLabel.hidden = true
                profileImageButtonTopMargin.constant = 12
            }
            
            if tweet.media == nil {
                mediaImageView.hidden = true
                mediaImageBottomSpace.constant = 0
                mediaImageHeight.constant = 0
            } else {
                mediaImageView.hidden = false
                mediaImageBottomSpace.constant = 12
                
                let url = NSURL(string: tweet.media!.mediaUrl!)
                let data = NSData(contentsOfURL : url!)
                let image = UIImage(data : data!)
                let width = mediaImageView.frame.size.width
                let newHeight = floor(image!.size.height * width / (image!.size.width))
                mediaImageHeight.constant = newHeight
                mediaImageView.image = image
                
//                mediaImageView.setImageWithURLRequest(NSURLRequest(URL: NSURL(string: tweet.media!.mediaUrl!)!), placeholderImage: nil, success: { (request: NSURLRequest, response: NSHTTPURLResponse?, image: UIImage) -> Void in
//                    let width = self.mediaImageView.frame.size.width
//                    let newHeight = floor(image.size.height * width / (image.size.width))
//                    self.mediaImageHeight.constant = newHeight
//                    self.mediaImageView.image = image
//                    }, failure: { (request: NSURLRequest, response: NSHTTPURLResponse?, error: NSError) -> Void in
//                        print(error.debugDescription)
//                })
            }
            
            refreshTweetData()
            
            
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

            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        self.layoutMargins = UIEdgeInsetsZero
        self.preservesSuperviewLayoutMargins = false
        
        profileImageButton.layer.cornerRadius = 5
        profileImageButton.clipsToBounds = true
        
        repostIcon.image = repostIcon.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        repostIcon.tintColor = customGrayColor
        
        let replyImage = UIImage(named: "icon_reply")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        replyBtn.setImage(replyImage, forState: UIControlState.Normal)
        replyBtn.tintColor = customGrayColor
        
        retweetBtn.setImage(retweetImage, forState: UIControlState.Normal)
        favBtn.setImage(favImage, forState: UIControlState.Normal)
        
        replyBtn.addTarget(self, action: "onReply:", forControlEvents: UIControlEvents.TouchUpInside)
        retweetBtn.addTarget(self, action: "onRetweet:", forControlEvents: UIControlEvents.TouchUpInside)
        favBtn.addTarget(self, action: "onFav:", forControlEvents: UIControlEvents.TouchUpInside)
        
        mediaImageView.layer.cornerRadius = 5
        mediaImageView.clipsToBounds = true
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
                    self.tweet.retweeted = tweet!.retweeted
                    self.tweet.retweetCount = tweet!.retweetCount
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
                    self.tweet.favorited = tweet!.favorited
                    self.tweet.favCount = tweet!.favCount
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
            retweetBtn.tintColor = retweetColor
            retweetCountLabel.textColor = retweetColor
        } else {
            retweetBtn.tintColor = customGrayColor
            retweetCountLabel.textColor = customGrayColor
        }
        
        if tweet.favorited {
            favBtn.tintColor = favColor
            favCountLabel.textColor = favColor
        } else {
            favBtn.tintColor = customGrayColor
            favCountLabel.textColor = customGrayColor
        }
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
