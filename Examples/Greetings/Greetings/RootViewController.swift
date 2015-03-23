//
//  RootViewController.swift
//  EMPageViewController
//
//  Created by Erik Malyak on 3/16/15.
//  Copyright (c) 2015 Erik Malyak. All rights reserved.
//

import UIKit

class RootViewController: UIViewController, EMPageViewControllerDataSource, EMPageViewControllerDelegate {

    @IBOutlet weak var reverseButton: UIButton!
    @IBOutlet weak var scrollToButton: UIButton!
    @IBOutlet weak var forwardButton: UIButton!
    
    var pageViewController: EMPageViewController?
    
    var greetings: [String] = ["Hello!", "¡Hola!", "Salut!", "Hallo!", "Ciao!"]
    var greetingColors: [UIColor] = [
        UIColor(red: 108.0/255.0, green: 122.0/255.0, blue: 137.0/255.0, alpha: 1.0),
        UIColor(red: 135.0/255.0, green: 211.0/255.0, blue: 124.0/255.0, alpha: 1.0),
        UIColor(red: 34.0/255.0, green: 167.0/255.0, blue: 240.0/255.0, alpha: 1.0),
        UIColor(red: 245.0/255.0, green: 171.0/255.0, blue: 53.0/255.0, alpha: 1.0),
        UIColor(red: 214.0/255.0, green: 69.0/255.0, blue: 65.0/255.0, alpha: 1.0)
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Instantiate EMPageViewController and set the data source and delegate to 'self'
        let pageViewController = EMPageViewController()
        pageViewController.dataSource = self
        pageViewController.delegate = self
        
        // Set the initially selected view controller
        let currentViewController = self.viewControllerAtIndex(0)!
        pageViewController.selectViewController(currentViewController, direction: .Forward, animated: false, completion: nil)
        
        // Add EMPageViewController to the root view controller
        self.addChildViewController(pageViewController)
        self.view.insertSubview(pageViewController.view, atIndex: 0) // Insert the page controller view below the navigation buttons
        pageViewController.didMoveToParentViewController(self)
        
        self.pageViewController = pageViewController
    }
    
    
    @IBAction func forward(sender: AnyObject) {
        self.pageViewController!.scrollForwardAnimated(true, completion: { (transitionSuccessful) in
        
            println(transitionSuccessful ? "true" : "false")
            
        })
    }
    
    @IBAction func reverse(sender: AnyObject) {
        self.pageViewController!.scrollReverseAnimated(true, completion: { (transitionSuccessful) in
            
            println(transitionSuccessful ? "true" : "false")
            
        })
    }
    
    @IBAction func scrollTo(sender: AnyObject) {
        
        let choiceViewController = UIAlertController(title: "Scroll To...", message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        let selectedIndex = self.indexOfViewController(self.pageViewController!.selectedViewController as GreetingViewController)
        
        for (index, viewControllerGreeting) in enumerate(greetings) {
            
            if (index != selectedIndex) {
            
                let action = UIAlertAction(title: viewControllerGreeting, style: UIAlertActionStyle.Default, handler: { (alertAction) in
                    
                    let viewController = self.viewControllerAtIndex(index)!
                    
                    let direction:EMPageViewControllerNavigationDirection = index > selectedIndex ? .Forward : .Reverse
                    
                    self.pageViewController!.selectViewController(viewController, direction: direction, animated: true, completion: nil)
                    
                })
                
                choiceViewController.addAction(action)
            }
        }
        
        let action = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
        choiceViewController.addAction(action)
        
        self.presentViewController(choiceViewController, animated: true, completion: nil)
        
    }
    
    // MARK: - EMPageViewController Data Source
    
    func em_pageViewController(pageViewController: EMPageViewController, viewControllerLeftOfViewController viewController: UIViewController) -> UIViewController? {
        if let viewControllerIndex = self.indexOfViewController(viewController as GreetingViewController) {
            let leftViewController = self.viewControllerAtIndex(viewControllerIndex - 1)
            return leftViewController
        } else {
            return nil
        }
    }
    
    func em_pageViewController(pageViewController: EMPageViewController, viewControllerRightOfViewController viewController: UIViewController) -> UIViewController? {
        if let viewControllerIndex = self.indexOfViewController(viewController as GreetingViewController) {
            let rightViewController = self.viewControllerAtIndex(viewControllerIndex + 1)
            return rightViewController
        } else {
            return nil
        }
    }
    
    func viewControllerAtIndex(index: Int) -> GreetingViewController? {
        if (self.greetings.count == 0) || (index < 0) || (index >= self.greetings.count) {
            return nil
        }
        
        let viewController = self.storyboard!.instantiateViewControllerWithIdentifier("GreetingViewController") as GreetingViewController
        viewController.greeting = self.greetings[index]
        viewController.color = self.greetingColors[index]
        return viewController
    }
    
    func indexOfViewController(viewController: GreetingViewController) -> Int? {
        if let greeting: String = viewController.greeting {
            return find(self.greetings, greeting)
        } else {
            return nil
        }
    }
    
    
    // MARK: - EMPageViewController Delegate

    func em_pageViewController(pageViewController: EMPageViewController, willStartScrollingFrom startingViewController: UIViewController, destinationViewController: UIViewController) {
        
        let startGreetingViewController = startingViewController as GreetingViewController
        let destinationGreetingViewController = destinationViewController as GreetingViewController
        
        println("Will start scrolling from \(startGreetingViewController.greeting!) to \(destinationGreetingViewController.greeting!)")
    }
    
    func em_pageViewController(pageViewController: EMPageViewController, isScrollingFrom startingViewController: UIViewController, destinationViewController: UIViewController, progress: CGFloat) {
        let startGreetingViewController = startingViewController as GreetingViewController
        let destinationGreetingViewController = destinationViewController as GreetingViewController
        
       println("Is scrolling from \(startGreetingViewController.greeting) to \(destinationGreetingViewController.greeting) with progress: \(progress)")
    }
    
    func em_pageViewController(pageViewController: EMPageViewController, didFinishScrollingFrom previousViewController: UIViewController?, selectedViewController: UIViewController, transitionSuccessful: Bool) {
        let previousGreetingViewController = previousViewController as GreetingViewController?
        let selectedViewController = selectedViewController as GreetingViewController
        
        if transitionSuccessful {
            
            if (self.indexOfViewController(selectedViewController) == 0) {
                self.reverseButton.enabled = false
            } else {
                self.reverseButton.enabled = true
            }
            
            if (self.indexOfViewController(selectedViewController) == self.greetings.count - 1) {
                self.forwardButton.enabled = false
            } else {
                self.forwardButton.enabled = true
            }
        }
        
        let success = transitionSuccessful ? "true" : "false"
        println("Finished scrolling from \(previousGreetingViewController?.greeting!) to \(selectedViewController.greeting!) - \(success)")
    }
    
}

