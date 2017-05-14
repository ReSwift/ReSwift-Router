//
//  SwiftFlowRouterTests.swift
//  SwiftFlowRouterTests
//
//  Created by Benjamin Encz on 12/2/15.
//  Copyright © 2015 DigiTales. All rights reserved.
//

import Quick
import Nimble
import ReSwift
@testable import ReSwiftRouter

class MockRoutable: Routable {

    var callsToPushRouteSegment: [(routeElement: RouteElementIdentifier, animated: Bool)] = []
    var callsToPopRouteSegment: [(routeElement: RouteElementIdentifier, animated: Bool)] = []
    var callsToChangeRouteSegment: [(
        from: RouteElementIdentifier,
        to: RouteElementIdentifier,
        animated: Bool
    )] = []

    func pushRouteSegment(
        _ routeElementIdentifier: RouteElementIdentifier,
        animated: Bool,
        completionHandler: @escaping RoutingCompletionHandler
        ) -> Routable {

        callsToPushRouteSegment.append(
            (routeElement: routeElementIdentifier, animated: animated)
        )
        completionHandler()
        return MockRoutable()
    }

    func popRouteSegment(
        _ routeElementIdentifier: RouteElementIdentifier,
        animated: Bool,
        completionHandler: @escaping RoutingCompletionHandler) {

        callsToPopRouteSegment.append(
            (routeElement: routeElementIdentifier, animated: animated)
        )
        completionHandler()
    }

    func changeRouteSegment(
        _ from: RouteElementIdentifier,
        to: RouteElementIdentifier,
        animated: Bool,
        completionHandler: @escaping RoutingCompletionHandler
        ) -> Routable {

        completionHandler()

        callsToChangeRouteSegment.append((from: from, to: to, animated: animated))

        return MockRoutable()
    }

}

struct FakeAppState: StateType {
    var navigationState = NavigationState()
}

func fakeReducer(action: Action, state: FakeAppState?) -> FakeAppState {
    return state ?? FakeAppState()
}

func appReducer(action: Action, state: FakeAppState?) -> FakeAppState {
    return FakeAppState(
        navigationState: NavigationReducer.handleAction(action, state: state?.navigationState)
    )
}

class SwiftFlowRouterIntegrationTests: QuickSpec {

    override func spec() {

        describe("routing calls") {

            var store: Store<FakeAppState>!

            beforeEach {
                store = Store(reducer: appReducer, state: FakeAppState())
            }

            describe("setup") {

                it("does not request the root view controller when no route is provided") {

                    class FakeRootRoutable: Routable {
                        var called = false

                        func pushRouteSegment(_ routeElementIdentifier: RouteElementIdentifier,
                            completionHandler: RoutingCompletionHandler) -> Routable {
                                called = true
                                return MockRoutable()
                        }
                    }

                    let routable = FakeRootRoutable()
                    let _ = Router(store: store, rootRoutable: routable) { state in
                        state.select { $0.navigationState }
                    }

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

                        init(calledWithIdentifier: @escaping (RouteElementIdentifier?) -> Void) {
                            self.calledWithIdentifier = calledWithIdentifier
                        }

                        func pushRouteSegment(_ routeElementIdentifier: RouteElementIdentifier, animated: Bool, completionHandler: @escaping RoutingCompletionHandler) -> Routable {
                                calledWithIdentifier(routeElementIdentifier)

                                completionHandler()
                                return MockRoutable()
                        }

                    }

                    waitUntil(timeout: 2.0) { fullfill in
                        let rootRoutable = FakeRootRoutable { identifier in
                            if identifier == "TabBarViewController" {
                                fullfill()
                            }
                        }

                        let _ = Router(store: store, rootRoutable: rootRoutable) { state in
                            state.select { $0.navigationState }
                        }
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

                        init(calledWithIdentifier: @escaping (RouteElementIdentifier?) -> Void) {
                            self.calledWithIdentifier = calledWithIdentifier
                        }

                        func pushRouteSegment(_ routeElementIdentifier: RouteElementIdentifier, animated: Bool, completionHandler: @escaping RoutingCompletionHandler) -> Routable {
                                calledWithIdentifier(routeElementIdentifier)

                                completionHandler()
                                return MockRoutable()
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

                            func pushRouteSegment(_ routeElementIdentifier: RouteElementIdentifier,
                                animated: Bool,
                                completionHandler: @escaping RoutingCompletionHandler) -> Routable {
                                    completionHandler()
                                    return injectedRoutable
                            }
                        }

                        let _ = Router(store: store, rootRoutable:
                            FakeRootRoutable(injectedRoutable: fakeChildRoutable)) { state in
                                state.select { $0.navigationState }
                            }
                    }
                }

            }

        }


        describe("route specific data") {

            var store: Store<FakeAppState>!

            beforeEach {
                store = Store(reducer: appReducer, state: nil)
            }

            context("when setting route specific data") {

                beforeEach {
                    store.dispatch(SetRouteSpecificData(route: ["part1", "part2"], data: "UserID_10"))
                }

                it("allows accessing the data when providing the expected type") {
                    let data: String? = store.state.navigationState.getRouteSpecificState(
                        ["part1", "part2"]
                    )

                    expect(data).toEventually(equal("UserID_10"))
                }
                
            }
            
        }

        describe("configuring animated/unanimated navigation") {

            var store: Store<FakeAppState>!
            var mockRoutable: MockRoutable!
            var router: Router<FakeAppState>!

            beforeEach {
                store = Store(reducer: appReducer, state: nil)
                mockRoutable = MockRoutable()
                router = Router(store: store, rootRoutable: mockRoutable) { state in
                    state.select { $0.navigationState }
                }

                // silence router not read warning, need to keep router alive via reference
                _ = router
            }

            context("when dispatching an animated route change") {
                beforeEach {
                    store.dispatch(SetRouteAction(["someRoute"], animated: true))
                }

                it("calls routables asking for an animated presentation") {
                    expect(mockRoutable.callsToPushRouteSegment.last?.animated).toEventually(beTrue())
                }
            }

            context("when dispatching an unanimated route change") {
                beforeEach {
                    store.dispatch(SetRouteAction(["someRoute"], animated: false))
                }

                it("calls routables asking for an animated presentation") {
                    expect(mockRoutable.callsToPushRouteSegment.last?.animated).toEventually(beFalse())
                }
            }

            context("when dispatching a default route change") {
                beforeEach {
                    store.dispatch(SetRouteAction(["someRoute"]))
                }

                it("calls routables asking for an animated presentation") {
                    expect(mockRoutable.callsToPushRouteSegment.last?.animated).toEventually(beTrue())
                }
            }
        }


    }
    
}
