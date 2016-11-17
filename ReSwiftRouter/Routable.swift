//
//  Routable.swift
//  Meet
//
//  Created by Benjamin Encz on 12/3/15.
//  Copyright © 2015 DigiTales. All rights reserved.
//

public typealias RoutingCompletionHandler = () -> Void

// For Routables that only need to push route segments
public protocol PushRoutable {
    func pushRouteSegment(
        _ routeElementIdentifier: RouteElementIdentifier,
        animated: Bool,
        completionHandler: @escaping RoutingCompletionHandler) -> Routable
}

// For Routables that only need to pop route segments
public protocol PopRoutable {
    func popRouteSegment(
        _ routeElementIdentifier: RouteElementIdentifier,
        animated: Bool,
        completionHandler: @escaping RoutingCompletionHandler)
}

// For Routables that only need to change route segments
public protocol ChangeRoutable {
    func changeRouteSegment(
        _ from: RouteElementIdentifier,
        to: RouteElementIdentifier,
        animated: Bool,
        completionHandler: @escaping RoutingCompletionHandler) -> Routable
}

// Convenience protocol for routables that can perform push, pop & change on segments
public protocol Routable: PushRoutable, PopRoutable, ChangeRoutable {}
    
