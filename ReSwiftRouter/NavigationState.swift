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

    public func segmentWith(identifier: UUID) -> RouteSegment? {
        if let segment = self.route.first(where: { $0.identifier == identifier }) {
            return segment
        }

        for segment in self.route {
            if let state = segment as? HasChildNavigationStates {
                for navigationState in state.childNavigationStates {
                    if let segment = navigationState.segmentWith(identifier: identifier) {
                        return segment
                    }
                }
            }
        }

        return nil
    }
}

public protocol HasNavigationState {
    var navigationState: NavigationState { get set }
}

public protocol HasChildNavigationStates {
    var childNavigationStates: [NavigationState] { get }
}
