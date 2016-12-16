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
            return self.setRoute(state: state, action: action)
        case let action as MutateRouteSegmentAction:
            return self.mutateComponent(state: state, action: action)
        default: break
        }

        return state
    }

    private static func setRoute(state: NavigationState, action: SetRouteAction) -> NavigationState {
        var state = state

        state.route = action.route
        state.changeRouteAnimated = action.animated
        state.shouldNavigate = action.navigate

        return state
    }

    private static func mutateComponent(state: NavigationState, action: MutateRouteSegmentAction) -> NavigationState {
        guard let index = state.route.index(where: { $0.identifier == action.component.identifier }) else { return state }

        var state = state

        state.route[index] = action.component
        state.shouldNavigate = false

        return state
    }
}
