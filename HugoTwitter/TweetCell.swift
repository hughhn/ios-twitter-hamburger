//
//  TweetCell.swift
//  HugoTwitter
//
//  Created by Hieu Nguyen on 2/19/16.
//  Copyright © 2016 Hugo Nguyen. All rights reserved.
//

import UIKit

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
            timestampLabel.text = "4h"
            tweetLabel.text = tweet.text
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        profileImageView.layer.cornerRadius = 5
        
        retweetedIcon.image = retweetedIcon.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        retweetedIcon.tintColor = UIColor.grayColor()
        
        replyIcon.image = replyIcon.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        replyIcon.tintColor = UIColor.grayColor()
        
        retweetIcon.image = retweetIcon.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        retweetIcon.tintColor = UIColor.grayColor()
        
        favIcon.image = favIcon.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        favIcon.tintColor = UIColor.grayColor()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
