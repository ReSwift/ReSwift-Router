//
//  Router.swift
//  Meet
//
//  Created by Benjamin Encz on 11/11/15.
//  Copyright © 2015 DigiTales. All rights reserved.
//

import ReSwift

public class Router<State: StateType>: StoreSubscriber {

    var store: MainStore<State>
    var lastNavigationState = NavigationState()
    var routables: [Routable] = []
    let waitForRoutingCompletionQueue = dispatch_queue_create("WaitForRoutingCompletionQueue", nil)

    public init(store: MainStore<State>, rootRoutable: Routable) {
        self.store = store
        self.routables.append(rootRoutable)

        self.store.subscribe(self)
    }

    public func newState(state: HasNavigationState) {
        let routingActions = Router.routingActionsForTransitionFrom(
            lastNavigationState.route, newRoute: state.navigationState.route)

        routingActions.forEach { routingAction in

            let semaphore = dispatch_semaphore_create(0)

            // Dispatch all routing actions onto this dedicated queue. This will ensure that
            // only one routing action can run at any given time. This is important for using this
            // Router with UI frameworks. Whenever a navigation action is triggered, this queue will
            // block (using semaphore_wait) until it receives a callback from the Routable 
            // indicating that the navigation action has completed
            dispatch_async(waitForRoutingCompletionQueue) {
                switch routingAction {

                case let .Pop(responsibleRoutableIndex, segmentToBePopped):
                    dispatch_async(dispatch_get_main_queue()) {
                        self.routables[responsibleRoutableIndex]
                            .popRouteSegment(segmentToBePopped) {
                            dispatch_semaphore_signal(semaphore)
                        }

                        self.routables.removeAtIndex(responsibleRoutableIndex + 1)
                    }

                case let .Change(responsibleRoutableIndex, segmentToBeReplaced, newSegment):
                    dispatch_async(dispatch_get_main_queue()) {
                        self.routables[responsibleRoutableIndex + 1] =
                            self.routables[responsibleRoutableIndex]
                                .changeRouteSegment(segmentToBeReplaced,
                                    to: newSegment) {
                                        dispatch_semaphore_signal(semaphore)
                        }
                    }

                case let .Push(responsibleRoutableIndex, segmentToBePushed):
                    dispatch_async(dispatch_get_main_queue()) {
                        self.routables.append(
                            self.routables[responsibleRoutableIndex]
                                .pushRouteSegment(segmentToBePushed) {
                                    dispatch_semaphore_signal(semaphore)
                            }
                        )
                    }
                }

                let waitUntil = dispatch_time(DISPATCH_TIME_NOW, Int64(3 * Double(NSEC_PER_SEC)))

                let result = dispatch_semaphore_wait(semaphore, waitUntil)

                if result != 0 {
                    assertionFailure("[SwiftFlowRouter]: Router is stuck waiting for a" +
                        " completion handler to be called. Ensure that you have called the " +
                        " completion handler in each Routable element.")
                }
            }

        }

        lastNavigationState = state.navigationState
    }

    // MARK: Route Transformation Logic

    static func largestCommonSubroute(oldRoute: [RouteElementIdentifier],
        newRoute: [RouteElementIdentifier]) -> Int {

            var largestCommonSubroute = -1

            while largestCommonSubroute + 1 < newRoute.count &&
                  largestCommonSubroute + 1 < oldRoute.count &&
                  newRoute[largestCommonSubroute + 1] == oldRoute[largestCommonSubroute + 1] {
                    largestCommonSubroute++
            }

            return largestCommonSubroute
    }

    // Maps Route index to Routable index. Routable index is offset by 1 because the root Routable
    // is not represented in the route, e.g.
    // route = ["tabBar"]
    // routables = [RootRoutable, TabBarRoutable]
    static func routableIndexForRouteSegment(segment: Int) -> Int {
        return segment + 1
    }

    static func routingActionsForTransitionFrom(oldRoute: [RouteElementIdentifier],
        newRoute: [RouteElementIdentifier]) -> [RoutingActions] {

            var routingActions: [RoutingActions] = []

            // Find the last common subroute between two routes
            let commonSubroute = largestCommonSubroute(oldRoute, newRoute: newRoute)

            if commonSubroute == oldRoute.count - 1 && commonSubroute == newRoute.count - 1 {
                return []
            }
            // Keeps track which element of the routes we are working on
            // We start at the end of the old route
            var routeBuildingIndex = oldRoute.count - 1

            // Pop all route segments of the old route that are no longer in the new route
            // Stop one element ahead of the commonSubroute. When we are one element ahead of the
            // commmon subroute we have three options:
            //
            // 1. The old route had an element after the commonSubroute and the new route does not
            //    we need to pop the route segment after the commonSubroute
            // 2. The old route had no element after the commonSubroute and the new route does, we
            //    we need to push the route segment(s) after the commonSubroute
            // 3. The new route has a different element after the commonSubroute, we need to replace
            //    the old route element with the new one
            while routeBuildingIndex > commonSubroute + 1 {
                let routeSegmentToPop = oldRoute[routeBuildingIndex]

                let popAction = RoutingActions.Pop(
                    responsibleRoutableIndex: routableIndexForRouteSegment(routeBuildingIndex - 1),
                    segmentToBePopped: routeSegmentToPop
                )

                routingActions.append(popAction)
                routeBuildingIndex--
            }

            // This is the 1. case:
            // "The old route had an element after the commonSubroute and the new route does not
            //  we need to pop the route segment after the commonSubroute"
            if oldRoute.count > newRoute.count {
                let popAction = RoutingActions.Pop(
                    responsibleRoutableIndex: routableIndexForRouteSegment(routeBuildingIndex - 1),
                    segmentToBePopped: oldRoute[routeBuildingIndex]
                )

                routingActions.append(popAction)
                routeBuildingIndex--
            }
            // This is the 3. case:
            // "The new route has a different element after the commonSubroute, we need to replace
            //  the old route element with the new one"
            else if oldRoute.count > (commonSubroute + 1) && newRoute.count > (commonSubroute + 1) {
                let changeAction = RoutingActions.Change(
                    responsibleRoutableIndex: routableIndexForRouteSegment(commonSubroute),
                    segmentToBeReplaced: oldRoute[commonSubroute + 1],
                    newSegment: newRoute[commonSubroute + 1])

                routingActions.append(changeAction)
            }

            // Push remainder of elements in new Route that weren't in old Route, this covers
            // the 2. case:
            // "The old route had no element after the commonSubroute and the new route does,
            //  we need to push the route segment(s) after the commonSubroute"
            let newRouteIndex = newRoute.count - 1

            while routeBuildingIndex < newRouteIndex {
                let routeSegmentToPush = newRoute[routeBuildingIndex + 1]

                let pushAction = RoutingActions.Push(
                    responsibleRoutableIndex: routableIndexForRouteSegment(routeBuildingIndex),
                    segmentToBePushed: routeSegmentToPush
                )

                routingActions.append(pushAction)
                routeBuildingIndex++
            }

            return routingActions
    }

}

enum RoutingActions {
    case Push(responsibleRoutableIndex: Int, segmentToBePushed: RouteElementIdentifier)
    case Pop(responsibleRoutableIndex: Int, segmentToBePopped: RouteElementIdentifier)
    case Change(responsibleRoutableIndex: Int, segmentToBeReplaced: RouteElementIdentifier,
                    newSegment: RouteElementIdentifier)
}
