//
//  NavigationController.swift
//  ReSwiftRouter
//
//  Created by Taras Vozniuk on 29/06/2017.
//  Copyright © 2017 Benjamin Encz. All rights reserved.
//

import UIKit

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
