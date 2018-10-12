//
//  NavigationAction.swift
//  Meet
//
//  Created by Benjamin Encz on 11/27/15.
//  Copyright © 2015 DigiTales. All rights reserved.
//

import ReSwift

public struct SetRouteAction: Action {

    let route: Route
    let animated: Bool
    public static let type = "RE_SWIFT_ROUTER_SET_ROUTE"

    public init (_ route: Route, animated: Bool = true) {
        self.route = route
        self.animated = animated
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
