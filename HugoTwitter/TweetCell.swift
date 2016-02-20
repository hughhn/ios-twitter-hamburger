//
//  TweetCell.swift
//  HugoTwitter
//
//  Created by Hieu Nguyen on 2/19/16.
//  Copyright © 2016 Hugo Nguyen. All rights reserved.
//

import UIKit

let customGrayColor = UIColor(red: 133.0/255.0, green: 133.0/255.0, blue: 133.0/255.0, alpha: 1.0)
var _dateFormatter = NSDateFormatter()

class TweetCell: UITableViewCell {

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
    
    @IBOutlet weak var profileImageTopMargin: NSLayoutConstraint!
    
    var tweet: Tweet! {
        didSet {
            profileImageView.setImageWithURL(NSURL(string: tweet.user!.profileImageUrl!)!)
            displayNameLabel.text = tweet.user!.name
            usernameLabel.text = "@\(tweet.user!.screenname!)"
            timestampLabel.text = DateManager.getFriendlyTime(tweet.createdAt!)
            tweetLabel.text = tweet.text
            if (tweet.isRetweet) {
                retweetLabel.text = "\(tweet.retweetName!) retweeted"
            } else {
                retweetLabel.hidden = true
                retweetedIcon.hidden = true
                profileImageTopMargin.constant = 8
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        profileImageView.layer.cornerRadius = 5
        
        retweetedIcon.image = retweetedIcon.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        retweetedIcon.tintColor = customGrayColor
        
        replyIcon.image = replyIcon.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        replyIcon.tintColor = customGrayColor
        
        retweetIcon.image = retweetIcon.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        retweetIcon.tintColor = customGrayColor
        
        favIcon.image = favIcon.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        favIcon.tintColor = customGrayColor
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
