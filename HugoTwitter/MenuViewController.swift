//
//  MenuViewController.swift
//  HugoTwitter
//
//  Created by Hieu Nguyen on 2/26/16.
//  Copyright © 2016 Hugo Nguyen. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var viewControllers: [UIViewController] = []
    
    var hamburgerViewController: HamburgerViewController!
    
    convenience init(withHamburger hamburgerViewController: HamburgerViewController?)
    {
        self.init(nibName: nil, bundle: nil)
        self.hamburgerViewController = hamburgerViewController!
        
        let menuNav = UINavigationController(rootViewController: self)
        
        hamburgerViewController!.menuViewController = menuNav
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let leftBtn = UIButton(type: .System)
        leftBtn.frame = CGRectMake(0, 0, 30, 30);
        let twitterImage = UIImage(named: "icon_twitter")
        leftBtn.setImage(twitterImage!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate), forState: UIControlState.Normal)
        leftBtn.tintColor = twitterColor
        
        let negativeSpacer = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FixedSpace, target: nil, action: nil)
        negativeSpacer.width = -10
        let leftBarBtn = UIBarButtonItem(customView: leftBtn)
        navigationItem.leftBarButtonItems = [negativeSpacer, leftBarBtn]
        
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorInset = UIEdgeInsetsZero
        tableView.registerNib(UINib(nibName: "MenuCell", bundle: nil), forCellReuseIdentifier: "MenuCell")
        
        let storyboard = UIStoryboard(name: "TweetsViewController", bundle: nil)
        
        let homeTimeline = storyboard.instantiateViewControllerWithIdentifier("TweetsViewController") as! TweetsViewController
        homeTimeline.tweetsEndpoint = TwitterClient.sharedInstance.homeTimeline
        let homeTimelineNav = UINavigationController(rootViewController: homeTimeline)
        
        let mentionsTimeline = storyboard.instantiateViewControllerWithIdentifier("TweetsViewController") as! TweetsViewController
        mentionsTimeline.tweetsEndpoint = TwitterClient.sharedInstance.mentionsTimeline
        let mentionsTimelineNav = UINavigationController(rootViewController: mentionsTimeline)
        
        let profile = storyboard.instantiateViewControllerWithIdentifier("ProfileViewController") as! ProfileViewController
        profile.profileEndpoint = TwitterClient.sharedInstance.userProfile
        if User.currentUser != nil && User.currentUser!.screenname != nil {
            profile.screenName = User.currentUser!.screenname
        }
        let profileNav = UINavigationController(rootViewController: profile)
        
        viewControllers.append(homeTimelineNav)
        viewControllers.append(mentionsTimelineNav)
        viewControllers.append(profileNav)
        
        // Initial view - home
//        hamburgerViewController.contentViewController = homeTimelineNav
        hamburgerViewController.contentViewController = profileNav
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewControllers.count + 1
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == viewControllers.count {
            let countDouble = CGFloat(viewControllers.count - 1)
            return tableView.bounds.height - (tableView.rowHeight * countDouble)
        }
        return tableView.rowHeight
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        hamburgerViewController.contentViewController = viewControllers[indexPath.row]
    }
    
    let homeImage = UIImage(named: "icon_compose")
    let mentionImage = UIImage(named: "icon_compose")
    let profileImage = UIImage(named: "icon_compose")
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MenuCell", forIndexPath: indexPath) as! MenuCell
        
        switch indexPath.row {
        case 0:
            cell.menuItemLabel.text = "Home"
            cell.menuItemImage.image = homeImage!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
            cell.menuItemImage.tintColor = twitterColor
        case 1:
            cell.menuItemLabel.text = "Mentions"
            cell.menuItemImage.image = mentionImage!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
            cell.menuItemImage.tintColor = UIColor.redColor()
        case 2:
            cell.menuItemLabel.text = "Profile"
            cell.menuItemImage.image = profileImage!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
            cell.menuItemImage.tintColor = UIColor.blueColor()
        default:
            cell.menuItemLabel.text = ""
            cell.menuItemImage.image = nil
            cell.menuItemImage.tintColor = UIColor.clearColor()
        }
        
        return cell
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
