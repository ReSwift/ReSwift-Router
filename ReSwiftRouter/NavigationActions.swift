//
//  NavigationAction.swift
//  Meet
//
//  Created by Benjamin Encz on 11/27/15.
//  Copyright © 2015 DigiTales. All rights reserved.
//

import ReSwift

/// Exports the type map needed for using ReSwiftRouter with a Recording Store
public let typeMap: [String: StandardActionConvertible.Type] =
    ["RE_SWIFT_ROUTER_SET_ROUTE": SetRouteAction.self]

public struct SetRouteAction: StandardActionConvertible {

    let route: Route
    let animated: Bool
    public static let type = "RE_SWIFT_ROUTER_SET_ROUTE"

    public init (_ route: Route, animated: Bool = true) {
        self.route = route
        self.animated = animated
    }

    public init(_ action: StandardAction) {
        self.route = action.payload!["route"] as! Route
        self.animated = action.payload!["animated"] as! Bool
    }

    public func toStandardAction() -> StandardAction {
        return StandardAction(
            type: SetRouteAction.type,
            payload: ["route": route as AnyObject, "animated": animated as AnyObject],
            isTypedAction: true
        )
    }
    
}

public struct SetRouteSpecificData: Action {

    let route: Route
    let data: Any

    public init(route: Route, data: Any) {
        self.route = route
        self.data = data
    }
}

public struct PushPathAction: StandardActionConvertible {

    let path: RouteElementIdentifier
    let animated: Bool
    public static let type = "RE_SWIFT_ROUTER_PUSH_PATH"

    public init(_ path: RouteElementIdentifier, animated: Bool = true) {
        self.path = path
        self.animated = animated
    }

    public init(_ action: StandardAction) {
        self.path = action.payload!["path"] as! RouteElementIdentifier
        self.animated = action.payload!["animated"] as! Bool
    }

    public func toStandardAction() -> StandardAction {
        return StandardAction(
            type: PushPathAction.type,
            payload: ["path": path as AnyObject, "animated": animated as AnyObject],
            isTypedAction: true
        )
    }
}

public struct PopPathAction: StandardActionConvertible {

    let animated: Bool
    public static let type = "RE_SWIFT_ROUTER_POP_PATH"

    public init(animated: Bool = true) {
        self.animated = animated
    }

    public init(_ action: StandardAction) {
        self.animated = action.payload!["animated"] as! Bool
    }

    public func toStandardAction() -> StandardAction {
        return StandardAction(
            type: PushPathAction.type,
            payload: ["animated": animated as AnyObject],
            isTypedAction: true
        )
    }
}
