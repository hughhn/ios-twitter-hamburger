//
//  TweetDetailedViewController.swift
//  HugoTwitter
//
//  Created by Hieu Nguyen on 2/20/16.
//  Copyright © 2016 Hugo Nguyen. All rights reserved.
//

import UIKit

class TweetDetailedViewController: UIViewController {

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
    @IBOutlet weak var replyIcon: UIImageView!
    @IBOutlet weak var retweetIcon: UIImageView!
    @IBOutlet weak var likeIcon: UIImageView!
    @IBOutlet weak var profileImageTopMargin: NSLayoutConstraint!
    
    var tweet: Tweet!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navigationController?.navigationBar.translucent = false;
        
        profileImageView.layer.cornerRadius = 5
        profileImageView.clipsToBounds = true
        
        repostIcon.image = repostIcon.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        repostIcon.tintColor = customGrayColor
        
        replyIcon.image = replyIcon.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        replyIcon.tintColor = customGrayColor
        
        retweetIcon.image = retweetIcon.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        retweetIcon.tintColor = customGrayColor
        
        likeIcon.image = likeIcon.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        likeIcon.tintColor = customGrayColor
        
        setupViews()
    }
    
    func setupViews() {
        profileImageView.setImageWithURL(NSURL(string: tweet.user!.profileImageUrl!)!)
        nameLabel.text = tweet.user!.name
        usernameLabel.text = "@\(tweet.user!.screenname!)"
        timeLabel.text = DateManager.getFriendlyTime(tweet.createdAt!)
        tweetLabel.text = tweet.text
        if (tweet.isRetweet) {
            repostLabel.text = "\(tweet.retweetName!) retweeted"
        } else {
            repostIcon.hidden = true
            repostLabel.hidden = true
            profileImageTopMargin.constant = 12
        }
    }
    
    override func viewDidLayoutSubviews() {
        navigationController?.navigationBar.translucent = false;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
