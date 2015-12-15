//
//  NavigationAction.swift
//  Meet
//
//  Created by Benjamin Encz on 11/27/15.
//  Copyright © 2015 DigiTales. All rights reserved.
//

import Foundation
import SwiftFlow

public struct SetRouteAction: ActionConvertible {

    let route: [RouteElementIdentifier]
    public static let type = "SWIFT_FLOW_ROUTER_SET_ROUTE"

    public init (_ route: [RouteElementIdentifier]) {
        self.route = route
    }

    public init(_ action: Action) {
        self.route = action.payload!["route"] as! [RouteElementIdentifier]
    }

    public func toAction() -> Action {
        return Action(type: SetRouteAction.type, payload: ["route": route])
    }
    
}