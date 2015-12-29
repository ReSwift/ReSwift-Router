//
//  SwiftFlowRouterTests.swift
//  SwiftFlowRouterTests
//
//  Created by Benjamin Encz on 12/2/15.
//  Copyright © 2015 DigiTales. All rights reserved.
//

import Quick
import Nimble
import SwiftFlow
@testable import SwiftFlowRouter

class FakeRoutable: Routable {


    func pushRouteSegment(routeSegment: RouteElementIdentifier,
        completionHandler: RoutingCompletionHandler) -> Routable {
            completionHandler()
            return FakeRoutable()
    }

    func popRouteSegment(routeSegment: RouteElementIdentifier,
        completionHandler: RoutingCompletionHandler) {
            completionHandler()
    }

    func changeRouteSegment(from: RouteElementIdentifier,
        to: RouteElementIdentifier,
        completionHandler: RoutingCompletionHandler) -> Routable {
            completionHandler()
            return FakeRoutable()
    }

}

struct FakeAppState: StateType, HasNavigationState {
    var navigationState = NavigationState()
}

class FakeReducer: Reducer {
    func handleAction(state: FakeAppState, action: Action) -> FakeAppState {
        return state
    }
}

class SwiftFlowRouterIntegrationTests: QuickSpec {

    override func spec() {

        describe("routing calls") {

            var store: MainStore!

            beforeEach {
                store = MainStore(reducer: CombinedReducer([NavigationReducer()]), appState: FakeAppState())
            }

            describe("setup") {

                it("does not request the root view controller when no route is provided") {

                    class FakeRootRoutable: Routable {
                        var called = false

                        func pushRouteSegment(routeElementIdentifier: RouteElementIdentifier,
                            completionHandler: RoutingCompletionHandler) -> Routable {
                                called = true
                                return FakeRoutable()
                        }
                    }

                    let routable = FakeRootRoutable()
                    let _ = Router(store: store, rootRoutable: routable)

                    expect(routable.called).to(beFalse())
                }

                it("requests the root with identifier when an initial route is provided") {
                    store.dispatch(
                        SetRouteAction(
                            ["TabBarViewController"]
                        )
                    )

                    class FakeRootRoutable: Routable {
                        var calledWithIdentifier: (RouteElementIdentifier?) -> Void

                        init(calledWithIdentifier: (RouteElementIdentifier?) -> Void) {
                            self.calledWithIdentifier = calledWithIdentifier
                        }

                        func pushRouteSegment(routeSegment: RouteElementIdentifier,
                            completionHandler: RoutingCompletionHandler) -> Routable {
                                calledWithIdentifier(routeSegment)

                                completionHandler()
                                return FakeRoutable()
                        }

                    }

                    waitUntil(timeout: 2.0) { fullfill in
                        let rootRoutable = FakeRootRoutable { identifier in
                            if identifier == "TabBarViewController" {
                                fullfill()
                            }
                        }

                        let _ = Router(store: store, rootRoutable: rootRoutable)
                    }
                }

                it("calls push on the root for a route with two elements") {
                    store.dispatch(

                        SetRouteAction(
                            ["TabBarViewController", "SecondViewController"]
                        )
                    )

                    class FakeChildRoutable: Routable {
                        var calledWithIdentifier: (RouteElementIdentifier?) -> Void

                        init(calledWithIdentifier: (RouteElementIdentifier?) -> Void) {
                            self.calledWithIdentifier = calledWithIdentifier
                        }

                        func pushRouteSegment(routeSegment: RouteElementIdentifier,
                            completionHandler: RoutingCompletionHandler) -> Routable {
                                calledWithIdentifier(routeSegment)

                                completionHandler()
                                return FakeRoutable()
                        }
                    }

                    waitUntil(timeout: 5.0) { completion in
                        let fakeChildRoutable = FakeChildRoutable() { identifier in
                            if identifier == "SecondViewController" {
                                completion()
                            }
                        }

                        class FakeRootRoutable: Routable {
                            let injectedRoutable: Routable

                            init(injectedRoutable: Routable) {
                                self.injectedRoutable = injectedRoutable
                            }

                            func pushRouteSegment(routeElementIdentifier: RouteElementIdentifier,
                                completionHandler: RoutingCompletionHandler) -> Routable {
                                    completionHandler()
                                    return injectedRoutable
                            }
                        }

                        let _ = Router(store: store, rootRoutable:
                            FakeRootRoutable(injectedRoutable: fakeChildRoutable))
                    }
                }

            }

        }
    }
    
}
