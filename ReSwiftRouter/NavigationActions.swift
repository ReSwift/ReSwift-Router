//
//  NavigationAction.swift
//  Meet
//
//  Created by Benjamin Encz on 11/27/15.
//  Copyright © 2015 DigiTales. All rights reserved.
//

import ReSwift

/// Exports the type map needed for using ReSwiftRouter with a Recording Store
//public let typeMap: [String: StandardActionConvertible.Type] =
//    ["RE_SWIFT_ROUTER_SET_ROUTE": SetRouteAction.self]

//public struct SetRouteAction: StandardActionConvertible {
//
//    let route: Route
//    let animated: Bool
//    public static let type = "RE_SWIFT_ROUTER_SET_ROUTE"
//
//    public init (_ route: Route, animated: Bool = true) {
//        self.route = route
//        self.animated = animated
//    }
//
//    public init(_ action: StandardAction) {
//        self.route = action.payload!["route"] as! Route
//        self.animated = action.payload!["animated"] as! Bool
//    }
//
//    public func toStandardAction() -> StandardAction {
//        return StandardAction(
//            type: SetRouteAction.type,
//            payload: ["route": route as AnyObject, "animated": animated as AnyObject],
//            isTypedAction: true
//        )
//    }
//    
//}

public struct SetRouteAction: Action {

    let route: [RouteSegment]
    let animated: Bool
    let navigate: Bool

    public init(route: [RouteSegment], animated: Bool = true, navigate: Bool = true) {
        self.route = route
        self.animated = animated
        self.navigate = navigate
    }
}

public struct MutateRouteSegmentAction: Action {
    let component: RouteSegment
}
