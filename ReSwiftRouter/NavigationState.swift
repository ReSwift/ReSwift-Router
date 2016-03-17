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

public struct RouteHash: Hashable {
    let routeHash: String

    init(route: Route) {
        self.routeHash = route.joinWithSeparator("/")
    }

    public var hashValue: Int { return self.routeHash.hashValue }
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
    public func getRouteSpecificState<T>(route: Route) -> T? {
        let hash = RouteHash(route: route)

        return self.routeSpecificState[hash] as? T
    }
}

public protocol HasNavigationState {
    var navigationState: NavigationState { get set }
}
