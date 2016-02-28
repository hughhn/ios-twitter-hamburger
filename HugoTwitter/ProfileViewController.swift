//
//  ProfileViewController.swift
//  HugoTwitter
//
//  Created by Hieu Nguyen on 2/26/16.
//  Copyright © 2016 Hugo Nguyen. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, TweetsViewControllerDelegate {

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var headerView: UIView!
    
    @IBOutlet weak var headerBackground: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var navNameLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var followingCountLabel: UILabel!
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var followerCountLabel: UILabel!
    @IBOutlet weak var followerLabel: UILabel!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    var headerImageView:UIImageView!
    var offsetHeaderViewStop: CGFloat!
    
    var viewControllers: [UIViewController] = []
    
    var selectedViewController: UIViewController?
    
    
    var screenName: String?
    var userId: String?
    
    var profileEndpoint: ((screenName: String?, userId: String?, params: NSDictionary?, completion: (user: User?, error: NSError?) -> ()) -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        segmentedControl.addTarget(self, action: "onTabChanged:", forControlEvents: UIControlEvents.ValueChanged)
        
        
        let storyboard = UIStoryboard(name: "TweetsViewController", bundle: nil)

        let tweetsViewController = storyboard.instantiateViewControllerWithIdentifier("TweetsViewController") as! TweetsViewController
        tweetsViewController.isStandaloneController = false
        tweetsViewController.tweetsEndpoint = TwitterClient.sharedInstance.homeTimeline
        tweetsViewController.delegate = self
        tweetsViewController.contentInsetHeight = headerView.frame.size.height
        
        let likesViewController = storyboard.instantiateViewControllerWithIdentifier("TweetsViewController") as! TweetsViewController
        likesViewController.isStandaloneController = false
        likesViewController.tweetsEndpoint = TwitterClient.sharedInstance.mentionsTimeline
        likesViewController.delegate = self
        likesViewController.contentInsetHeight = headerView.frame.size.height
        
        viewControllers.append(tweetsViewController)
        viewControllers.append(likesViewController)
        
        // Initial Tab
        selectViewController(viewControllers[0])
        
        headerImageView = UIImageView(frame: headerBackground.bounds)
        headerImageView?.contentMode = UIViewContentMode.ScaleAspectFill
        headerBackground.insertSubview(headerImageView, atIndex: 0)
        
        profileImageView.layer.cornerRadius = 5
        profileImageView.clipsToBounds = true
        
        
        navigationController!.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        navigationController!.navigationBar.shadowImage = UIImage()
        navigationController!.navigationBar.translucent = true;
        navigationController!.view.backgroundColor = UIColor.clearColor()
        navigationController!.navigationBar.backgroundColor = UIColor.clearColor()
        
        let navHeight = navigationController!.navigationBar.frame.size.height + navigationController!.navigationBar.frame.origin.y
        offsetHeaderViewStop = segmentedControl.frame.origin.y - navHeight
        
        profileEndpoint?(screenName: screenName, userId: userId, params: nil, completion: { (user, error) -> () in
            if user != nil {
                self.loadViewWithUser(user!)
            }
        })
    }
    
    func loadViewWithUser(user: User!) {
        nameLabel.text = user.name!
        navNameLabel.text = user.name!
        screenNameLabel.text = "@\(user.screenname!)"
        
        loadLowResThenHighResImg(profileImageView, smallImageUrl: user.profileImageLowResUrl!, largeImageUrl: user.profileImageUrl!, duration: 1.0)
        fadeInImg(headerImageView, imageUrl: user.profileBackgroundImageUrl!, duration: 1.0)
    }
    
    func selectViewController(viewController: UIViewController) {
        if let oldViewController = selectedViewController {
            oldViewController.willMoveToParentViewController(nil)
            oldViewController.view.removeFromSuperview()
            oldViewController.removeFromParentViewController()
        }
        self.addChildViewController(viewController)
        viewController.view.frame = self.contentView.bounds
        viewController.view.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        self.contentView.addSubview(viewController.view)
        viewController.didMoveToParentViewController(self)
    }
    
    func onTabChanged(sender: UISegmentedControl) {
        let selectedSegment = sender.selectedSegmentIndex
        selectViewController(viewControllers[selectedSegment])
    }
    
    var initialOffset: CGFloat? = nil
    var initialHeaderViewOffset: CGFloat? = nil
    func tweetsViewOnScroll(scrollView: UIScrollView) {
        if initialOffset == nil {
            initialOffset = scrollView.contentOffset.y
            initialHeaderViewOffset = headerView.frame.origin.y
        }
        
        let offset = scrollView.contentOffset.y - initialOffset!
        
        
        let shouldTransform = (offsetHeaderViewStop - offset > 0.0)
        if !shouldTransform {
            return
        }
        
        var headerTransform = CATransform3DIdentity
        headerTransform = CATransform3DTranslate(headerTransform, 0, max(-offsetHeaderViewStop, -offset), 0)
        headerView.layer.transform = headerTransform
        
        
        if offset < 0 {
            // Pull down
            
            
        } else {
            // Scroll up/down
            
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
