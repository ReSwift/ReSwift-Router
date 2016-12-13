//
//  NavigationState.swift
//  Meet
//
//  Created by Benjamin Encz on 11/11/15.
//  Copyright © 2015 DigiTales. All rights reserved.
//

import ReSwift

public struct NavigationState {
    public init() {}

    public var route: [RouteSegment] = []
    var changeRouteAnimated: Bool = true
    var shouldNavigate: Bool = true // Set to false if the router should not respond to state change

    public func segmentWith(instanceIdentifier: UUID) -> RouteSegment? {
        return self.route.first(where: { $0.instanceIdentifier == instanceIdentifier })
    }
}

public protocol HasNavigationState {
    var navigationState: NavigationState { get set }
}
