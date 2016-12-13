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
        _ route: RouteSegment,
        animated: Bool,
        completionHandler: @escaping RoutingCompletionHandler) -> Routable

    func popRouteSegment(
        _ route: RouteSegment,
        animated: Bool,
        completionHandler: @escaping RoutingCompletionHandler)

    func changeRouteSegment(
        _ from: RouteSegment,
        to: RouteSegment,
        animated: Bool,
        completionHandler: @escaping RoutingCompletionHandler) -> Routable
    
}

public extension Routable {

    func pushRouteSegment(
        _ route: RouteSegment,
        animated: Bool,
        completionHandler: @escaping RoutingCompletionHandler) -> Routable {
        fatalError("This routable cannot change segments. You have not implemented it.")
    }

    func popRouteSegment(
        _ route: RouteSegment,
        animated: Bool,
        completionHandler: @escaping RoutingCompletionHandler) {
        fatalError("This routable cannot change segments. You have not implemented it.")
    }

    func changeRouteSegment(
        _ from: RouteSegment,
        to: RouteSegment,
        animated: Bool,
        completionHandler: @escaping RoutingCompletionHandler) -> Routable {
        fatalError("This routable cannot change segments. You have not implemented it.")
    }

}
