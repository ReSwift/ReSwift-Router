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

}

extension Routable {

    public func pushRouteSegment(
        _ routeElementIdentifier: RouteElementIdentifier,
        animated: Bool,
        completionHandler: @escaping RoutingCompletionHandler) -> Routable {
            fatalError("This routable cannot push segments. You have not implemented it. (Asked \(type(of: self)) to push \(routeElementIdentifier))")
    }

    public func popRouteSegment(
        _ routeElementIdentifier: RouteElementIdentifier,
        animated: Bool,
        completionHandler: @escaping RoutingCompletionHandler) {
            fatalError("This routable cannot pop segments. You have not implemented it. (Asked \(type(of: self)) to pop \(routeElementIdentifier))")
    }

    public func changeRouteSegment(
        _ from: RouteElementIdentifier,
        to: RouteElementIdentifier,
        animated: Bool,
        completionHandler: @escaping RoutingCompletionHandler) -> Routable {
            fatalError("This routable cannot change segments. You have not implemented it. (Asked \(type(of: self)) to change from \(from) to \(to))")
    }

}
