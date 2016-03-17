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
        routeElementIdentifier: RouteElementIdentifier,
        animated: Bool,
        completionHandler: RoutingCompletionHandler) -> Routable

    func popRouteSegment(
        routeElementIdentifier: RouteElementIdentifier,
        animated: Bool,
        completionHandler: RoutingCompletionHandler)

    func changeRouteSegment(
        from: RouteElementIdentifier,
        to: RouteElementIdentifier,
        animated: Bool,
        completionHandler: RoutingCompletionHandler) -> Routable

}

extension Routable {

    public func pushRouteSegment(
        routeElementIdentifier: RouteElementIdentifier,
        animated: Bool,
        completionHandler: RoutingCompletionHandler) -> Routable {
            fatalError("This routable cannot change segments. You have not implemented it.")
    }

    public func popRouteSegment(
        routeElementIdentifier: RouteElementIdentifier,
        animated: Bool,
        completionHandler: RoutingCompletionHandler) {
            fatalError("This routable cannot change segments. You have not implemented it.")
    }

    public func changeRouteSegment(
        from: RouteElementIdentifier,
        to: RouteElementIdentifier,
        animated: Bool,
        completionHandler: RoutingCompletionHandler) -> Routable {
            fatalError("This routable cannot change segments. You have not implemented it.")
    }

}
