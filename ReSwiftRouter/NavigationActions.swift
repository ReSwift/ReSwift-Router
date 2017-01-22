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
    let completionAction: Action?
    public static let type = "RE_SWIFT_ROUTER_SET_ROUTE"

    public init (_ route: Route, animated: Bool = true, completionAction: Action? = nil) {
        self.route = route
        self.animated = animated
        self.completionAction = completionAction
    }

    public init(_ action: StandardAction) {
        self.route = action.payload!["route"] as! Route
        self.animated = action.payload!["animated"] as! Bool
        self.completionAction = action.payload!["completionAction"] as? Action
    }

    public func toStandardAction() -> StandardAction {
        return StandardAction(
            type: SetRouteAction.type,
            payload: getPayload(),
            isTypedAction: true
        )
    }
    
    private func getPayload() -> [String: AnyObject] {
        var payload = ["route": route as AnyObject,
                       "animated": animated as AnyObject]
        if let completionAction = completionAction {
            payload["completionAction"] = completionAction as AnyObject
        }
        return payload
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
