//
//  Routable.swift
//  Meet
//
//  Created by Benjamin Encz on 12/3/15.
//  Copyright © 2015 DigiTales. All rights reserved.
//

public typealias RoutingCompletionHandler = () -> Void

public protocol Routable {

    func changeRouteSegment(from: RouteElementIdentifier,
        to: RouteElementIdentifier,
        completionHandler: RoutingCompletionHandler) -> Routable

    func pushRouteSegment(routeElementIdentifier: RouteElementIdentifier,
        completionHandler: RoutingCompletionHandler) -> Routable

    func popRouteSegment(routeElementIdentifier: RouteElementIdentifier,
        completionHandler: RoutingCompletionHandler)

}

extension Routable {
    public func changeRouteSegment(from: RouteElementIdentifier,
        to: RouteElementIdentifier, completionHandler: RoutingCompletionHandler) -> Routable {
            fatalError("This routable cannot change segments. You have not implemented it.")
    }

    public func popRouteSegment(routeElementIdentifier: RouteElementIdentifier,
        completionHandler: RoutingCompletionHandler) {
            fatalError("This routable cannot change segments. You have not implemented it.")
    }

    public func pushRouteSegment(routeElementIdentifier: RouteElementIdentifier,
        completionHandler: RoutingCompletionHandler) -> Routable {
            fatalError("This routable cannot change segments. You have not implemented it.")
    }
}
