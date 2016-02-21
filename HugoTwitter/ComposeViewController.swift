//
//  ComposeViewController.swift
//  HugoTwitter
//
//  Created by Hieu Nguyen on 2/20/16.
//  Copyright © 2016 Hugo Nguyen. All rights reserved.
//

import UIKit

@objc protocol ComposeViewControllerDelegate {
    optional func onTweetSend(composeViewController: ComposeViewController, tweet: String!, replyToTweet: Tweet?)
    optional func onComposeViewClosed(composeViewController: ComposeViewController, tweet: String!)
}

extension String {
    var length: Int {
        return characters.count
    }
}

let MAX_CHARS = 140

class ComposeViewController: UIViewController, UITextViewDelegate {

    weak var delegate: ComposeViewControllerDelegate?
    
    var user: User?
    var replyToTweet: Tweet?
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var closeBtn: UIButton!
    @IBOutlet weak var tweetTextView: UITextView!
    @IBOutlet weak var placeHolderLabel: UILabel!
    
    var counterLabel: UILabel!
    var tweetBtn: UIButton!
    var flexButton, counterBarBtn, tweetBarBtn, negativeSpacer: UIBarButtonItem!
    var toolbar = UIToolbar()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        profileImageView.layer.cornerRadius = 5
        profileImageView.clipsToBounds = true
        if user != nil {
            loadLowResThenHighResImg(profileImageView, smallImageUrl: user!.profileImageLowResUrl!, largeImageUrl: user!.profileImageUrl!, duration: 0)
        }
        
        let closeImage = UIImage(named: "icon_close")
        closeBtn.setImage(closeImage!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate), forState: UIControlState.Normal)
        closeBtn.tintColor = twitterColor
        
        tweetTextView.delegate = self
        tweetTextView.becomeFirstResponder()
        
        setupAccessoryToolbar()
    }
    
    func setupAccessoryToolbar() {
        toolbar.barStyle = UIBarStyle.Default
        
        counterLabel = UILabel(frame: CGRectMake(0.0 , 0, 30, 40))
        counterLabel.font = UIFont(name: "GothamBook-Regular", size: 14)
        counterLabel.backgroundColor = UIColor.clearColor()
        counterLabel.textColor = UIColor.lightGrayColor()
        counterLabel.text = "\(140)"
        counterBarBtn = UIBarButtonItem(customView: counterLabel)
        
        tweetBtn = UIButton(type: .System)
        tweetBtn.frame = CGRectMake(0, 0, 70, 40);
        tweetBtn.backgroundColor = twitterColor
        tweetBtn.layer.cornerRadius = 5
        tweetBtn.titleLabel?.font = UIFont(name: "GothamBold-Regular", size: 14)
        tweetBtn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        tweetBtn.setTitle("Tweet", forState: UIControlState.Normal)
        tweetBtn.addTarget(self, action: "onTweet", forControlEvents: UIControlEvents.TouchUpInside)
        tweetBarBtn = UIBarButtonItem(customView: tweetBtn)
        
        flexButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        negativeSpacer = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FixedSpace, target: nil, action: nil)
        negativeSpacer.width = -10
        
        toolbar.setItems([flexButton, counterBarBtn, tweetBarBtn, negativeSpacer], animated: false)
        toolbar.sizeToFit()
        
        tweetTextView.inputAccessoryView = toolbar
    }
    
    func onTweet() {
        delegate?.onTweetSend?(self, tweet: tweetTextView.text, replyToTweet: replyToTweet)
        delegate?.onComposeViewClosed?(self, tweet: tweetTextView.text)
    }
    
    func textViewDidChange(textView: UITextView) {
        if textView.text == "" {
            placeHolderLabel.hidden = false
        } else {
            placeHolderLabel.hidden = true
        }
        
        let counter = MAX_CHARS - textView.text.length
        counterLabel.text = "\(counter)"
        if counter < 0 {
            counterLabel.textColor = UIColor.redColor()
            tweetBtn.backgroundColor = UIColor.lightGrayColor()
            tweetBtn.enabled = false
        } else {
            counterLabel.textColor = UIColor.lightGrayColor()
            tweetBtn.backgroundColor = twitterColor
            tweetBtn.enabled = true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onClose(sender: AnyObject) {
        delegate?.onComposeViewClosed?(self, tweet: tweetTextView.text)
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
