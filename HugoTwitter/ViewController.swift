//
//  ViewController.swift
//  HugoTwitter
//
//  Created by Hieu Nguyen on 2/16/16.
//  Copyright © 2016 Hugo Nguyen. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onLoginClicked(sender: AnyObject) {
        TwitterClient.sharedInstance.loginWithCompletion { (user, error) -> () in
            if user != nil {
                print("loginCompleted, user: \(user!.name!)")
                //self.performSegueWithIdentifier("loginSegue", sender: self)
                
                let hamburgerVC = HamburgerViewController()
                let menuVC = MenuViewController(withHamburger: hamburgerVC)
                self.presentViewController(hamburgerVC, animated: true, completion: nil)
            } else {
                // handle error
            }
        }
    }

}

