//
//  NavigationReducer.swift
//  Meet
//
//  Created by Benjamin Encz on 11/11/15.
//  Copyright © 2015 DigiTales. All rights reserved.
//

import UIKit
import SwiftFlow

public struct NavigationReducer: Reducer {

    public init() {}

    public func handleAction(state: HasNavigationState, action: Action) -> HasNavigationState {
        switch action.type {
        case SetRouteAction.type:
            return setRoute(state, route: SetRouteAction(action).route)
        default:
            break
        }

        return state
    }

    func setRoute(var state: HasNavigationState, route: [RouteElementIdentifier]) -> HasNavigationState {
        state.navigationState.route = route

        return state
    }

}