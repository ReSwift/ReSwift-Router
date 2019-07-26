//
//  Router.swift
//  Meet
//
//  Created by Benjamin Encz on 11/11/15.
//  Copyright © 2015 DigiTales. All rights reserved.
//

import Foundation
import ReSwift

open class Router<State: StateType>: StoreSubscriber {

    public typealias NavigationStateTransform = (Subscription<State>) -> Subscription<NavigationState>

    var store: Store<State>
    var lastNavigationState = NavigationState()
    var routables: [Routable] = []
    let waitForRoutingCompletionQueue = DispatchQueue(label: "WaitForRoutingCompletionQueue", attributes: [])

    public init(store: Store<State>, rootRoutable: Routable,  stateTransform: @escaping NavigationStateTransform) {
        self.store = store 
        self.routables.append(rootRoutable)
        self.store.subscribe(self, transform: stateTransform)
    }

    open func newState(state: NavigationState) {
      let routingActions = Router.routingActionsForTransition(from: lastNavigationState.route,
                                                              to: state.route)

        routingActions.forEach { routingAction in

            let semaphore = DispatchSemaphore(value: 0)

            // Dispatch all routing actions onto this dedicated queue. This will ensure that
            // only one routing action can run at any given time. This is important for using this
            // Router with UI frameworks. Whenever a navigation action is triggered, this queue will
            // block (using semaphore_wait) until it receives a callback from the Routable 
            // indicating that the navigation action has completed
            waitForRoutingCompletionQueue.async {
                switch routingAction {

                case let .pop(responsibleRoutableIndex, segmentToBePopped):
                    DispatchQueue.main.async {
                        self.routables[responsibleRoutableIndex]
                            .popRouteSegment(
                                segmentToBePopped,
                                animated: state.changeRouteAnimated) {
                                    semaphore.signal()
                        }

                        self.routables.remove(at: responsibleRoutableIndex + 1)
                    }

                case let .change(responsibleRoutableIndex, segmentToBeReplaced, newSegment):
                    DispatchQueue.main.async {
                        self.routables[responsibleRoutableIndex + 1] =
                            self.routables[responsibleRoutableIndex]
                                .changeRouteSegment(
                                    segmentToBeReplaced,
                                    to: newSegment,
                                    animated: state.changeRouteAnimated) {
                                        semaphore.signal()
                        }
                    }

                case let .push(responsibleRoutableIndex, segmentToBePushed):
                    DispatchQueue.main.async {
                        self.routables.append(
                            self.routables[responsibleRoutableIndex]
                                .pushRouteSegment(
                                    segmentToBePushed,
                                    animated: state.changeRouteAnimated) {
                                        semaphore.signal()
                            }
                        )
                    }
                }

                let waitUntil = DispatchTime.now() + Double(Int64(3 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)

                let result = semaphore.wait(timeout: waitUntil)

                if case .timedOut = result {
                    print("[ReSwiftRouter]: Router is stuck waiting for a" +
                        " completion handler to be called. Ensure that you have called the" +
                        " completion handler in each Routable element.")
                    print("Set a symbolic breakpoint for the `ReSwiftRouterStuck` symbol in order" +
                        " to halt the program when this happens")
                    ReSwiftRouterStuck()
                }
            }

        }

        lastNavigationState = state
    }

    // MARK: Route Transformation Logic

    static func largestCommonSubroute(_ oldRoute: Route, newRoute: Route) -> Int {
            var largestCommonSubroute = -1

            while largestCommonSubroute + 1 < newRoute.count &&
                  largestCommonSubroute + 1 < oldRoute.count &&
                  newRoute[largestCommonSubroute + 1] == oldRoute[largestCommonSubroute + 1] {
                    largestCommonSubroute += 1
            }

            return largestCommonSubroute
    }

    // Maps Route index to Routable index. Routable index is offset by 1 because the root Routable
    // is not represented in the route, e.g.
    // route = ["tabBar"]
    // routables = [RootRoutable, TabBarRoutable]
    static func routableIndex(for segment: Int) -> Int {
      return segment + 1
    }

    static func routingActionsForTransition(
      from oldRoute: Route,
      to newRoute: Route) -> [RoutingActions] {

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

                let popAction = RoutingActions.pop(
                    responsibleRoutableIndex: routableIndex(for: routeBuildingIndex - 1),
                    segmentToBePopped: routeSegmentToPop
                )

                routingActions.append(popAction)
                routeBuildingIndex -= 1
            }

            // This is the 3. case:
            // "The new route has a different element after the commonSubroute, we need to replace
            //  the old route element with the new one"
             if oldRoute.count > (commonSubroute + 1) && newRoute.count > (commonSubroute + 1) {
                let changeAction = RoutingActions.change(
                    responsibleRoutableIndex: routableIndex(for: commonSubroute),
                    segmentToBeReplaced: oldRoute[commonSubroute + 1],
                    newSegment: newRoute[commonSubroute + 1])
                
                routingActions.append(changeAction)
            }
            // This is the 1. case:
            // "The old route had an element after the commonSubroute and the new route does not
            //  we need to pop the route segment after the commonSubroute"
            else if oldRoute.count > newRoute.count {
                let popAction = RoutingActions.pop(
                    responsibleRoutableIndex: routableIndex(for: routeBuildingIndex - 1),
                    segmentToBePopped: oldRoute[routeBuildingIndex]
                )

                routingActions.append(popAction)
                routeBuildingIndex -= 1
            }
        

            // Push remainder of elements in new Route that weren't in old Route, this covers
            // the 2. case:
            // "The old route had no element after the commonSubroute and the new route does,
            //  we need to push the route segment(s) after the commonSubroute"
            let newRouteIndex = newRoute.count - 1

            while routeBuildingIndex < newRouteIndex {
                let routeSegmentToPush = newRoute[routeBuildingIndex + 1]

                let pushAction = RoutingActions.push(
                    responsibleRoutableIndex: routableIndex(for: routeBuildingIndex),
                    segmentToBePushed: routeSegmentToPush
                )

                routingActions.append(pushAction)
                routeBuildingIndex += 1
            }

            return routingActions
    }

}

func ReSwiftRouterStuck() {}

enum RoutingActions {
    case push(responsibleRoutableIndex: Int, segmentToBePushed: RouteElementIdentifier)
    case pop(responsibleRoutableIndex: Int, segmentToBePopped: RouteElementIdentifier)
    case change(responsibleRoutableIndex: Int, segmentToBeReplaced: RouteElementIdentifier,
                    newSegment: RouteElementIdentifier)
}
