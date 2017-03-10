//
//  Routable.swift
//  Meet
//
//  Created by Benjamin Encz on 12/3/15.
//  Copyright © 2015 DigiTales. All rights reserved.
//

public typealias RoutingCompletionHandler = () -> Void

public protocol Routable {

    func pushRouteSegment(
        _ routeElementIdentifier: RouteElementIdentifier,
        animated: Bool,
        completionHandler: @escaping RoutingCompletionHandler) -> Routable

    func popRouteSegment(
        _ routeElementIdentifier: RouteElementIdentifier,
        animated: Bool,
        completionHandler: @escaping RoutingCompletionHandler)

    func changeRouteSegment(
        _ from: RouteElementIdentifier,
        to: RouteElementIdentifier,
        animated: Bool,
        completionHandler: @escaping RoutingCompletionHandler) -> Routable

    func canPush(segment: RouteElementIdentifier) -> Bool

    func canPop(segment: RouteElementIdentifier) -> Bool

    func canChange(segment: RouteElementIdentifier) -> Bool
}

extension Routable {

    public func pushRouteSegment(
        _ routeElementIdentifier: RouteElementIdentifier,
        animated: Bool,
        completionHandler: @escaping RoutingCompletionHandler) -> Routable {
            fatalError("This routable cannot change segments. You have not implemented it.")
    }

    public func popRouteSegment(
        _ routeElementIdentifier: RouteElementIdentifier,
        animated: Bool,
        completionHandler: @escaping RoutingCompletionHandler) {
            fatalError("This routable cannot change segments. You have not implemented it.")
    }

    public func changeRouteSegment(
        _ from: RouteElementIdentifier,
        to: RouteElementIdentifier,
        animated: Bool,
        completionHandler: @escaping RoutingCompletionHandler) -> Routable {
            fatalError("This routable cannot change segments. You have not implemented it.")
    }

    public func canPush(segment: RouteElementIdentifier) -> Bool {
        return true
    }

    public func canPop(segment: RouteElementIdentifier) -> Bool {
        return true
    }

    public func canChange(segment: RouteElementIdentifier) -> Bool {
        return true
    }
}
