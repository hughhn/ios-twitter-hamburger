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
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
