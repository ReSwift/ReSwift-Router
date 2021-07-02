//
//  SwiftFlowRouterTests.swift
//  SwiftFlowRouterTests
//
//  Created by Benjamin Encz on 12/2/15.
//  Copyright © 2015 ReSwift Community. All rights reserved.
//

import Quick
import Nimble
import ReSwift
import Dispatch
@testable import ReSwiftRouter

class MockRoutable: Routable {

    var callsToPushRouteElement: [(routeElement: RouteElement, animated: Bool)] = []
    var callsToPopRouteElement: [(routeElement: RouteElement, animated: Bool)] = []
    var callsToChangeRouteElement: [(
        from: RouteElement,
        to: RouteElement,
        animated: Bool
    )] = []

    func push(
        _ element: RouteElement,
        animated: Bool,
        completion: @escaping RoutingCompletion
        ) -> Routable {

        callsToPushRouteElement.append(
            (routeElement: element, animated: animated)
        )
        completion()
        return MockRoutable()
    }

    func pop(
        _ element: RouteElement,
        animated: Bool,
        completion: @escaping RoutingCompletion) {

        callsToPopRouteElement.append(
            (routeElement: element, animated: animated)
        )
        completion()
    }

    func change(
        _ from: RouteElement,
        to: RouteElement,
        animated: Bool,
        completion: @escaping RoutingCompletion
        ) -> Routable {

        completion()

        callsToChangeRouteElement.append((from: from, to: to, animated: animated))

        return MockRoutable()
    }

}

struct FakeAppState {
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

                        func push(_ element: RouteElement,
                            completion: RoutingCompletion) -> Routable {
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

                it("requests the root with element when an initial route is provided") {
                    store.dispatch(
                        SetRouteAction(
                            ["TabBarViewController"]
                        )
                    )

                    class FakeRootRoutable: Routable {
                        var calledWithElement: (RouteElement?) -> Void

                        init(calledWithElement: @escaping (RouteElement?) -> Void) {
                            self.calledWithElement = calledWithElement
                        }

                        func push(_ element: RouteElement, animated: Bool, completion: @escaping RoutingCompletion) -> Routable {
                                calledWithElement(element)

                                completion()
                                return MockRoutable()
                        }

                    }

                    waitUntil(timeout: .seconds(2)) { fullfill in
                        let rootRoutable = FakeRootRoutable { element in
                            if element == "TabBarViewController" {
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
                        var calledWithElement: (RouteElement?) -> Void

                        init(calledWithElement: @escaping (RouteElement?) -> Void) {
                            self.calledWithElement = calledWithElement
                        }

                        func push(_ element: RouteElement, animated: Bool, completion: @escaping RoutingCompletion) -> Routable {
                                calledWithElement(element)

                                completion()
                                return MockRoutable()
                        }
                    }

                    waitUntil(timeout: .seconds(5)) { completion in
                        let fakeChildRoutable = FakeChildRoutable() { element in
                            if element == "SecondViewController" {
                                completion()
                            }
                        }

                        class FakeRootRoutable: Routable {
                            let injectedRoutable: Routable

                            init(injectedRoutable: Routable) {
                                self.injectedRoutable = injectedRoutable
                            }

                            func push(_ element: RouteElement,
                                animated: Bool,
                                completion: @escaping RoutingCompletion) -> Routable {
                                    completion()
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
                    expect(mockRoutable.callsToPushRouteElement.last?.animated).toEventually(beTrue())
                }
            }

            context("when dispatching an unanimated route change") {
                beforeEach {
                    store.dispatch(SetRouteAction(["someRoute"], animated: false))
                }

                it("calls routables asking for an animated presentation") {
                    expect(mockRoutable.callsToPushRouteElement.last?.animated).toEventually(beFalse())
                }
            }

            context("when dispatching a default route change") {
                beforeEach {
                    store.dispatch(SetRouteAction(["someRoute"]))
                }

                it("calls routables asking for an animated presentation") {
                    expect(mockRoutable.callsToPushRouteElement.last?.animated).toEventually(beTrue())
                }
            }
        }


    }

}
