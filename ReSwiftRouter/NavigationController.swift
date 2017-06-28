//
//  NavigationController.swift
//  ReSwiftRouter
//
//  Created by Taras Vozniuk on 29/06/2017.
//  Copyright © 2017 Benjamin Encz. All rights reserved.
//

import UIKit

// dummy view controller returned when popViewController is canceled
final class PopWasIgnored: UIViewController {}

open class NavigationController: UINavigationController {
    
    fileprivate var isSwipping: Bool = false
    
    // indicates that backButton was pressed when set to false
    fileprivate var isPerformingPop: Bool = false
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        self.interactivePopGestureRecognizer?.addTarget(self, action: #selector(NavigationController.handlePopSwipe))
        self.delegate = self
    }
    
    override open func popViewController(animated: Bool) -> UIViewController? {
        
        // when swipping we are discarding all subsequent popViewController calls
        guard !self.isSwipping else {
            return PopWasIgnored()
        }
        
        self.isPerformingPop = true
        return super.popViewController(animated: animated)
    }
    
    // will be called after popViewController call
    func handlePopSwipe(){
        self.isSwipping = true
    }
    
    /// should be overriden
    /// normally you should dispatch SetRouteAction here
    open func changeRoute(){
        print("WARNING: \(#function) should to be overriden")
    }
}

extension NavigationController: UINavigationControllerDelegate {
    
    public func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        self.isSwipping = false
    }
}

extension NavigationController: UINavigationBarDelegate {
    
    // if overriden navigationController popViewController won't be called before this method
    // on back button press
    // isPerformingPop will be false here in this case
    public func navigationBar(_ navigationBar: UINavigationBar, shouldPop item: UINavigationItem) -> Bool {
        defer { isPerformingPop = false }
        
        // changeRoute is performed:
        // 1. back button was pressed
        // 2. pop swipe is triggerred
        if !isPerformingPop || self.isSwipping {
            self.changeRoute()
        }
        
        // don't remove the navigationItem if navigationController
        // is not going to be popped
        return isPerformingPop
    }
}

extension UINavigationController {
    
    func pushViewController(_ viewController: UIViewController, animated: Bool, completion: @escaping () -> Void) {
        
        self.pushViewController(viewController, animated: animated)
        
        guard animated, let coordinator = self.transitionCoordinator else {
            completion()
            return
        }
        
        coordinator.animate(alongsideTransition: nil) { _ in completion() }
    }
    
    func popViewController(animated: Bool, completion: @escaping () -> Void) -> UIViewController? {
        
        let popped = self.popViewController(animated: animated)
        
        guard animated, let coordinator = self.transitionCoordinator else {
            completion()
            return popped
        }
        
        coordinator.animate(alongsideTransition: nil) { _ in completion() }
        return popped
    }
}
