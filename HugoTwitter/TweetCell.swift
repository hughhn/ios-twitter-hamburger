//
//  TweetCell.swift
//  HugoTwitter
//
//  Created by Hieu Nguyen on 2/19/16.
//  Copyright © 2016 Hugo Nguyen. All rights reserved.
//

import UIKit

class TweetCell: UITableViewCell {

    @IBOutlet weak var repostIcon: UIImageView!
    @IBOutlet weak var repostLabel: UILabel!
    @IBOutlet weak var retweetLabel: UILabel!
    @IBOutlet weak var displayNameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var tweetLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var retweetedIcon: UIImageView!
    @IBOutlet weak var replyIcon: UIImageView!
    @IBOutlet weak var retweetIcon: UIImageView!
    @IBOutlet weak var favIcon: UIImageView!
    
    @IBOutlet weak var replyBtn: UIButton!
    @IBOutlet weak var retweetBtn: UIButton!
    @IBOutlet weak var favBtn: UIButton!
    @IBOutlet weak var retweetCountLabel: UILabel!
    @IBOutlet weak var favCountLabel: UILabel!
    
    @IBOutlet weak var profileImageTopMargin: NSLayoutConstraint!
    
    var tweet: Tweet! {
        didSet {
            loadLowResThenHighResImg(profileImageView, smallImageUrl: tweet.user!.profileImageLowResUrl!, largeImageUrl: tweet.user!.profileImageUrl!, duration: 0)
            displayNameLabel.text = tweet.user!.name
            usernameLabel.text = "@\(tweet.user!.screenname!)"
            timestampLabel.text = DateManager.getFriendlyTime(tweet.createdAt!)
            tweetLabel.text = tweet.text
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
    }
    
    func refreshTweetData() {
        retweetCountLabel.text = "\(tweet.retweetCount)"
        favCountLabel.text = "\(tweet.favCount)"
        
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

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
