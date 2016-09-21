//
//  NavigationReducer.swift
//  Meet
//
//  Created by Benjamin Encz on 11/11/15.
//  Copyright © 2015 DigiTales. All rights reserved.
//

import ReSwift

/** 
 The Navigation Reducer handles the state slice concerned with storing the current navigation
 information. Note, that this reducer is **not** a *top-level* reducer, you need to use it within
 another reducer and pass in the relevant state slice. Take a look at the specs to see an
 example set up. 
 */
public struct NavigationReducer {

    public static func handleAction(_ action: Action, state: NavigationState?) -> NavigationState {
        let state = state ?? NavigationState()

        switch action {
        case let action as SetRouteAction:
            return setRoute(state, setRouteAction: action)
        case let action as SetRouteSpecificData:
            return setRouteSpecificData(state, route: action.route, data: action.data)
        default:
            break
        }

        return state
    }

    static func setRoute(_ state: NavigationState, setRouteAction: SetRouteAction) -> NavigationState {
        var state = state

        state.route = setRouteAction.route
        state.changeRouteAnimated = setRouteAction.animated

        return state
    }

    static func setRouteSpecificData(
        _ state: NavigationState,
        route: Route,
        data: Any) -> NavigationState{
            let routeHash = RouteHash(route: route)

            var state = state

            state.routeSpecificState[routeHash] = data

            return state
    }

}
