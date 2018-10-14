//
//  Routable.swift
//  Meet
//
//  Created by Benjamin Encz on 12/3/15.
//  Copyright © 2015 DigiTales. All rights reserved.
//

public typealias RoutingCompletionHandler = () -> Void

public protocol Routable {

    func push(
        _ element: RouteElement,
        animated: Bool,
        completionHandler: @escaping RoutingCompletionHandler) -> Routable

    func pop(
        _ element: RouteElement,
        animated: Bool,
        completionHandler: @escaping RoutingCompletionHandler)

    func change(
        _ from: RouteElement,
        to: RouteElement,
        animated: Bool,
        completionHandler: @escaping RoutingCompletionHandler) -> Routable

}

extension Routable {

    public func push(
        _ element: RouteElement,
        animated: Bool,
        completionHandler: @escaping RoutingCompletionHandler) -> Routable {
            fatalError("This routable cannot push elements. You have not implemented it. (Asked \(type(of: self)) to push \(element))")
    }

    public func pop(
        _ element: RouteElement,
        animated: Bool,
        completionHandler: @escaping RoutingCompletionHandler) {
            fatalError("This routable cannot pop elements. You have not implemented it. (Asked \(type(of: self)) to pop \(element))")
    }

    public func change(
        _ from: RouteElement,
        to: RouteElement,
        animated: Bool,
        completionHandler: @escaping RoutingCompletionHandler) -> Routable {
            fatalError("This routable cannot change elements. You have not implemented it. (Asked \(type(of: self)) to change from \(from) to \(to))")
    }

}
