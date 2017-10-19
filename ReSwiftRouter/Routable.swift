//
//  Routable.swift
//  Meet
//
//  Created by Benjamin Encz on 12/3/15.
//  Copyright © 2015 DigiTales. All rights reserved.
//

/// Human-readable typealias for the completion handler, which _must_ run in all paths to unblock the internal `semaphore_wait()`
public typealias RoutingCompletionHandler = () -> Void

public protocol Routable {

    /// Push a valid route onto the stack.
    ///
    /// Should trigger `fatalError()` if the route being pushed does not exist or otherwise is not supported for any reason.
    ///
    /// _Must_ pass along `completionHandler` or ultimately call it, to unblock the `semaphore_wait()` used internally.
    ///
    /// - Parameters:
    ///   - routeElementIdentifier: the route identifier to push
    ///   - animated: whether or not to animate the transition
    ///   - completionHandler: the callback to run on completion of the navigation event.
    /// - Returns: a valid routable to keep on the stack.
    func pushRouteSegment(
        _ routeElementIdentifier: RouteElementIdentifier,
        animated: Bool,
        completionHandler: @escaping RoutingCompletionHandler) -> Routable

    /// Pop a valid route off the stack.
    ///
    /// Should trigger `fatalError()` if the route being popped does not exist or otherwise is not supported for any reason.
    ///
    /// _Must_ pass along `completionHandler` or ultimately call it, to unblock the `semaphore_wait()` used internally.
    ///
    /// - Parameters:
    ///   - routeElementIdentifier: the route identifier to pop
    ///   - animated: whether or not to animate the transition
    ///   - completionHandler: the callback to run on completion of the navigation event.
    func popRouteSegment(
        _ routeElementIdentifier: RouteElementIdentifier,
        animated: Bool,
        completionHandler: @escaping RoutingCompletionHandler)

    /// Swap the current route with another, valid route.
    ///
    /// Should trigger `fatalError()` if the route to be added does not exist or otherwise is not supported for any reason.
    ///
    /// _Must_ pass along `completionHandler` or ultimately call it, to unblock the `semaphore_wait()` used internally.
    ///
    /// - Parameters:
    ///   - routeElementIdentifier: the route identifier to change to
    ///   - animated: whether or not to animate the transition
    ///   - completionHandler: the callback to run on completion of the navigation event.
    /// - Returns: a valid routable to keep on the stack.
    func changeRouteSegment(
        _ from: RouteElementIdentifier,
        to: RouteElementIdentifier,
        animated: Bool,
        completionHandler: @escaping RoutingCompletionHandler) -> Routable

}

extension Routable {

    /// Predetermined inability to push a route onto the stack.
    ///
    /// All Routable-implementing classes should override this function to avoid runtime errors with `fatalError()`.
    ///
    /// - Parameters:
    ///   - routeElementIdentifier: the route identifier to push
    ///   - animated: whether or not to animate the transition
    ///   - completionHandler: the callback to run on completion of the navigation event.
    /// - Returns: a valid routable to keep on the stack.
    public func pushRouteSegment(
        _ routeElementIdentifier: RouteElementIdentifier,
        animated: Bool,
        completionHandler: @escaping RoutingCompletionHandler) -> Routable {
            fatalError("This routable cannot push segments. You have not implemented it. (Asked \(type(of: self)) to push \(routeElementIdentifier))")
    }

    /// Predetermined inability to pop the current route off the stack.
    ///
    /// All Routable-implementing classes should override this function to avoid runtime errors with `fatalError()`.
    ///
    /// - Parameters:
    ///   - routeElementIdentifier: the current route identifier
    ///   - animated: whether or not to animate the transition
    ///   - completionHandler: the callback to run on completion of the navigation event.
    public func popRouteSegment(
        _ routeElementIdentifier: RouteElementIdentifier,
        animated: Bool,
        completionHandler: @escaping RoutingCompletionHandler) {
            fatalError("This routable cannot pop segments. You have not implemented it. (Asked \(type(of: self)) to pop \(routeElementIdentifier))")
    }

    /// Predetermined inability to swap the current route with another, valid route.
    ///
    /// All Routable-implementing classes should override this function to avoid runtime errors with `fatalError()`.
    ///
    /// - Parameters:
    ///   - from: the current route identifier
    ///   - to: the route identifier to change to
    ///   - animated: whether or not to animate the transition
    ///   - completionHandler: the callback to run on completion of the navigation event.
    /// - Returns: a valid routable to keep on the stack.
    public func changeRouteSegment(
        _ from: RouteElementIdentifier,
        to: RouteElementIdentifier,
        animated: Bool,
        completionHandler: @escaping RoutingCompletionHandler) -> Routable {
            fatalError("This routable cannot change segments. You have not implemented it. (Asked \(type(of: self)) to change from \(from) to \(to))")
    }

}
