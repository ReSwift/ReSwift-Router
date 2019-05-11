//
//  NavigationState.swift
//  Meet
//
//  Created by Benjamin Encz on 11/11/15.
//  Copyright © 2015 DigiTales. All rights reserved.
//

import ReSwift

public typealias RouteElementIdentifier = String
public typealias Route = [RouteElementIdentifier]

/// A `Hashable` and `Equatable` presentation of a route.
/// Can be used to check two routes for equality.
public struct RouteHash: Hashable {
    let routeHash: String

    public init(route: Route) {
        self.routeHash = route.joined(separator: "/")
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(routeHash)
    }
}

public func == (lhs: RouteHash, rhs: RouteHash) -> Bool {
    return lhs.routeHash == rhs.routeHash
}

public struct NavigationState {
    public init() {}

    public var route: Route = []
    public var routeSpecificState: [RouteHash: Any] = [:]
    var changeRouteAnimated: Bool = true
}

extension NavigationState {
    public func getRouteSpecificState<T>(_ route: Route) -> T? {
        let hash = RouteHash(route: route)

        return self.routeSpecificState[hash] as? T
    }
}

public protocol HasNavigationState {
    var navigationState: NavigationState { get set }
}
