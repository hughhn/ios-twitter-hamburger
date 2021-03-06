//
//  ProfileViewController.swift
//  HugoTwitter
//
//  Created by Hieu Nguyen on 2/26/16.
//  Copyright © 2016 Hugo Nguyen. All rights reserved.
//

import UIKit
import FXBlurView

class ProfileViewController: UIViewController, TweetsViewControllerDelegate, UIGestureRecognizerDelegate, ComposeViewControllerDelegate {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var headerView: UIView!
    
    @IBOutlet weak var headerBackground: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var navNameLabel: UILabel!
    @IBOutlet weak var navSublabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var followingCountLabel: UILabel!
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var followerCountLabel: UILabel!
    @IBOutlet weak var followerLabel: UILabel!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBOutlet weak var profileImageTopMargin: NSLayoutConstraint!
    @IBOutlet weak var headerImageView:UIImageView!
    @IBOutlet weak var blurredHeaderImageView: UIImageView!
    @IBOutlet weak var lineHeightConstraint: NSLayoutConstraint!
    
    var offsetHeaderViewStop: CGFloat!
    var offsetHeader: CGFloat?
    var offsetHeaderBackgroundViewStop: CGFloat!
    var offsetNavLabelViewStop: CGFloat!
    
    
    var viewControllers: [UIViewController] = []
    
    var selectedViewController: UIViewController?
    var pan: UIPanGestureRecognizer!
    var navHeight: CGFloat!
    
    var screenName: String?
    var userId: String?
    var user: User?
    
    var profileEndpoint: ((screenName: String?, userId: String?, params: NSDictionary?, completion: (user: User?, error: NSError?) -> ()) -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        segmentedControl.addTarget(self, action: "onTabChanged:", forControlEvents: UIControlEvents.ValueChanged)
        segmentedControl.tintColor = twitterColor
        segmentedControl.setTitle("Tweets", forSegmentAtIndex: 0)
        segmentedControl.setTitle("Likes", forSegmentAtIndex: 1)
        
        var params = NSMutableDictionary()
        if screenName != nil {
            params.setValue(screenName!, forKey: "screen_name")
        } else if userId != nil {
            params.setValue(userId!, forKey: "user_id")
        }
        
        let storyboard = UIStoryboard(name: "TweetsViewController", bundle: nil)

        let tweetsViewController = storyboard.instantiateViewControllerWithIdentifier("TweetsViewController") as! TweetsViewController
        tweetsViewController.isStandaloneController = false
        tweetsViewController.params = params
        tweetsViewController.tweetsEndpoint = TwitterClient.sharedInstance.userTweets
        tweetsViewController.delegate = self
        tweetsViewController.contentInsetHeight = headerView.frame.size.height
        tweetsViewController.view.layoutIfNeeded()
        
        let likesViewController = storyboard.instantiateViewControllerWithIdentifier("TweetsViewController") as! TweetsViewController
        likesViewController.isStandaloneController = false
        likesViewController.params = params
        likesViewController.tweetsEndpoint = TwitterClient.sharedInstance.userLikes
        likesViewController.delegate = self
        likesViewController.contentInsetHeight = headerView.frame.size.height
        likesViewController.view.layoutIfNeeded()
        
        viewControllers.append(tweetsViewController)
        viewControllers.append(likesViewController)
        
        // Initial Tab
        selectViewController(viewControllers[0])
        
        navHeight = navigationController!.navigationBar.frame.size.height + navigationController!.navigationBar.frame.origin.y
        offsetHeaderViewStop = segmentedControl.frame.origin.y - navHeight - 8
        offsetHeaderBackgroundViewStop = (headerBackground.frame.size.height + headerBackground.frame.origin.y) - navHeight
        offsetNavLabelViewStop = navNameLabel.frame.origin.y - (navHeight / 2) + 8
        
        headerBackground.clipsToBounds = true
        lineHeightConstraint.constant = 1 / UIScreen.mainScreen().scale
        
        profileImageView.layer.cornerRadius = 10
        profileImageView.clipsToBounds = true
        profileImageView.layer.borderColor = UIColor.whiteColor().CGColor
        profileImageView.layer.borderWidth = 4.0
        profileImageTopMargin.constant = navHeight + 4.0
        profileImageView.layer.zPosition = 1
        let border = CAShapeLayer()
        let uiBezierPath = UIBezierPath.bezierPathByReversingPath(UIBezierPath(roundedRect: profileImageView.bounds, cornerRadius: self.profileImageView.layer.cornerRadius))
        border.path = uiBezierPath().CGPath
        border.strokeColor = UIColor.whiteColor().CGColor
        border.fillColor = UIColor.clearColor().CGColor
        profileImageView.layer.addSublayer(border)
        
        pan = UIPanGestureRecognizer(target: self, action: Selector("onPanGesture:"))
        pan.delegate = self
        //headerView.addGestureRecognizer(pan)
        
        profileEndpoint?(screenName: screenName, userId: userId, params: nil, completion: { (user, error) -> () in
            if user != nil {
                self.loadViewWithUser(user!)
            }
        })
    }
    
    override func viewWillAppear(animated: Bool) {
        setupNavBar()
    }
    
    override func viewWillDisappear(animated: Bool) {
        navigationController!.navigationBar.setBackgroundImage(nil, forBarMetrics: UIBarMetrics.Default)
        navigationController!.navigationBar.tintColor = twitterColor
    }
    
    func setupNavBar() {
        navigationController!.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        navigationController!.navigationBar.shadowImage = UIImage()
        navigationController!.navigationBar.translucent = true;
        navigationController!.view.backgroundColor = UIColor.clearColor()
        navigationController!.navigationBar.backgroundColor = UIColor.clearColor()
        
        let negativeSpacer = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FixedSpace, target: nil, action: nil)
        negativeSpacer.width = -10
        
        let rightBtn = UIButton(type: .System)
        rightBtn.frame = CGRectMake(0, 0, 30, 30);
        let composeImage = UIImage(named: "icon_compose")
        rightBtn.setImage(composeImage!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate), forState: UIControlState.Normal)
        rightBtn.tintColor = UIColor.whiteColor()
        rightBtn.addTarget(self, action: "onCompose", forControlEvents: UIControlEvents.TouchUpInside)
        
        let rightBarBtn = UIBarButtonItem(customView: rightBtn)
        navigationItem.rightBarButtonItems = [negativeSpacer, rightBarBtn]
        
        setupNavigationForBackBtn()
    }
    
    func loadViewWithUser(user: User!) {
        self.user = user
        nameLabel.text = user.name!
        navNameLabel.text = user.name!
        screenNameLabel.text = "@\(user.screenname!)"
        followingCountLabel.text = "\(user.followingCount!.prettify())"
        followerCountLabel.text = "\(user.followersCount!.prettify())"
        
        if segmentedControl.selectedSegmentIndex == 0 {
            navSublabel.text = "\(self.user!.tweetsCount!.prettify()) Tweets"
        } else {
            navSublabel.text = "\(self.user!.likesCount!.prettify()) Likes"
        }

        loadLowResThenHighResImg(profileImageView, smallImageUrl: user.profileImageLowResUrl!, largeImageUrl: user.profileImageUrl!, duration: 1.0)
        //fadeInImg(headerImageView, imageUrl: user.profileBackgroundImageUrl!, duration: 1.0)
        
        headerImageView.setImageWithURLRequest(NSURLRequest(URL: NSURL(string: user.profileBackgroundImageUrl!)!), placeholderImage: nil, success: { (request, response, image) -> Void in
            
            
            self.headerImageView.image = image
            self.blurredHeaderImageView.image = image.blurredImageWithRadius(10, iterations: 20, tintColor: UIColor.clearColor())
            self.blurredHeaderImageView.alpha = 0.0
            
            
            }) { (request, response, error) -> Void in
                print(error.debugDescription)
        }
    }
    
    func selectViewController(viewController: UIViewController) {
        var contentOffset: CGPoint?
        if let oldViewController = selectedViewController {
            if oldViewController.isKindOfClass(TweetsViewController.classForCoder()) {
                let oldTweetsVC = oldViewController as! TweetsViewController
                contentOffset = oldTweetsVC.tableView.contentOffset
            }
            oldViewController.willMoveToParentViewController(nil)
            oldViewController.view.removeFromSuperview()
            oldViewController.removeFromParentViewController()
        }
        
        self.addChildViewController(viewController)
        viewController.view.frame = self.contentView.bounds
        viewController.view.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        self.contentView.addSubview(viewController.view)
        viewController.didMoveToParentViewController(self)
        selectedViewController = viewController
        
        if contentOffset != nil && viewController.isKindOfClass(TweetsViewController.classForCoder()) {
            let newTweetsVC = viewController as! TweetsViewController
            let currFrameOffset = min(contentOffset!.y, headerView.frame.size.height)
            let newFrameOffset = min(newTweetsVC.tableView.contentOffset.y, headerView.frame.size.height)
            
            if newFrameOffset != currFrameOffset {
                newTweetsVC.tableView.setContentOffset(CGPoint(x: 0, y: currFrameOffset), animated: false)
            }
        }
    }
    
    func onTabChanged(sender: UISegmentedControl) {
        let selectedSegment = sender.selectedSegmentIndex
        selectViewController(viewControllers[selectedSegment])
        
        if self.user != nil {
            if selectedSegment == 0 {
                navSublabel.text = "\(self.user!.tweetsCount!.prettify()) Tweets"
            } else {
                navSublabel.text = "\(self.user!.likesCount!.prettify()) Likes"
            }
        }
        
    }
    
    var startPoint: CGPoint!
    func onPanGesture(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translationInView(gesture.view)
        
        if gesture.state == UIGestureRecognizerState.Changed {
//            let tweetsVC = viewControllers[0] as! TweetsViewController
//            tweetsVC.tableView.contentOffset = CGPoint(x: 0, y: -translation.y)
            
            var scrollInfo: [NSObject : AnyObject] = [:]
            scrollInfo[ScrollNotificationKey] = -translation.y
            NSNotificationCenter.defaultCenter().postNotificationName(ScrollNotification, object: self, userInfo: scrollInfo)
        }
    }
    
    var initialOffset: CGFloat? = nil
    func tweetsViewOnScroll(scrollView: UIScrollView) {
        if initialOffset == nil {
            initialOffset = scrollView.contentOffset.y
        }
        
        let offset = scrollView.contentOffset.y - initialOffset!
        offsetHeader = max(-offsetHeaderViewStop, -offset)
            
        var headerTransform = CATransform3DIdentity
        headerTransform = CATransform3DTranslate(headerTransform, 0, offsetHeader!, 0)
        headerView.layer.transform = headerTransform
        
        var headerBackgroundTransform = CATransform3DIdentity
        if offset < 0 {
            let headerImageScaleFactor = (-offset) / headerBackground.bounds.height
            let headerImageHeightChanged = headerImageScaleFactor * headerBackground.bounds.height / 2.0
            headerBackgroundTransform = CATransform3DTranslate(headerBackgroundTransform, 0, headerImageHeightChanged, 0)
            headerBackgroundTransform = CATransform3DScale(headerBackgroundTransform, 1.0 + headerImageScaleFactor, 1.0 + headerImageScaleFactor, 0)
            
            //print ("scale delta = \(headerImageScaleFactor) ; height delta = \(headerImageHeightChanged)")
        } else {
            headerBackgroundTransform = CATransform3DTranslate(headerBackgroundTransform, 0, max(-offsetHeaderBackgroundViewStop, -offset), 0)
        }
        headerBackground.layer.transform = headerBackgroundTransform
        
        if offset < 0 {
            blurredHeaderImageView.alpha = min(1.0, fabs(offset/offsetHeaderBackgroundViewStop))
        } else {
            blurredHeaderImageView.alpha = min(1.0, (offset - offsetHeaderBackgroundViewStop) / offsetNavLabelViewStop)
        }
        
        
        let labelTransform = CATransform3DMakeTranslation(0, max(-offsetNavLabelViewStop, -offset), 0)
        navNameLabel.layer.transform = labelTransform
        navSublabel.layer.transform = labelTransform
        
        var avatarTransform = CATransform3DIdentity
        if offset < 0 {
            // pull down
            avatarTransform = CATransform3DTranslate(avatarTransform, 0, -offset, 0)
        } else {
            let avatarScaleFactor = (min(offsetHeaderBackgroundViewStop, offset)) / profileImageView.bounds.height / 1.4 // Slow down the animation
            let avatarHeightChanged = profileImageView.bounds.height * avatarScaleFactor
            avatarTransform = CATransform3DScale(avatarTransform, 1.0 - avatarScaleFactor, 1.0 - avatarScaleFactor, 0)
            
            var avatarYTranslation = avatarHeightChanged
            if offset > offsetHeaderBackgroundViewStop {
                avatarYTranslation += (offset - offsetHeaderBackgroundViewStop) * 1.5
            }
            avatarTransform = CATransform3DTranslate(avatarTransform, 0, -avatarYTranslation, 0)
            //print("-avatarYTranslation \(-avatarYTranslation) ; scaleFactor = \(avatarScaleFactor)")
            
        }
        profileImageView.layer.transform = avatarTransform

        
        if offset <= offsetHeaderBackgroundViewStop {
            if profileImageView.layer.zPosition < headerBackground.layer.zPosition{
                headerBackground.layer.zPosition = profileImageView.layer.zPosition - 1
                navNameLabel.layer.zPosition = headerBackground.layer.zPosition
                navSublabel.layer.zPosition = headerBackground.layer.zPosition
            }
        } else {
            if profileImageView.layer.zPosition >= headerBackground.layer.zPosition{
                headerBackground.layer.zPosition = profileImageView.layer.zPosition + 1
                navNameLabel.layer.zPosition = headerBackground.layer.zPosition + 1
                navSublabel.layer.zPosition = headerBackground.layer.zPosition + 1
            }
        }
    }
    
    
    func setupNavigationForBackBtn() {
        if navigationController == nil {
            return
        }
        
        let stackCount = navigationController!.viewControllers.count - 2
        if stackCount >= 0 {
            navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        }
    }
    
    func onCompose() {
        let composeVC = ComposeViewController()
        composeVC.delegate = self
        composeVC.user = User.currentUser
        navigationController?.presentViewController(composeVC, animated: true, completion: nil)
    }

    func onComposeViewClosed(composeViewController: ComposeViewController, tweetStatus: String!) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func onTweetSend(composeViewController: ComposeViewController, tweetStatus: String!, replyToTweet: Tweet?) {
        dismissViewControllerAnimated(true, completion: nil)
        
        var params = ["status": tweetStatus]
        if replyToTweet != nil {
            params["in_reply_to_status_id"] = replyToTweet!.id!
        }
        
        TwitterClient.sharedInstance.updateStatus(params as! NSDictionary) { (tweet, error) -> () in
            
            var tweetComposedInfo: [NSObject : AnyObject] = [:]
            tweetComposedInfo[TweetComposeNotificationKey] = tweet
            NSNotificationCenter.defaultCenter().postNotificationName(TweetComposeNotification, object: self, userInfo: tweetComposedInfo)
            
        }
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
