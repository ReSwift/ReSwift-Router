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

    var callsToPushRouteSegment: [(routeElement: RouteSegment, animated: Bool)] = []
    var callsToPopRouteSegment: [(routeElement: RouteSegment, animated: Bool)] = []
    var callsToChangeRouteSegment: [(
        from: RouteSegment,
        to: RouteSegment,
        animated: Bool
    )] = []

    func pushRouteSegment(
        _ routeElementIdentifier: RouteSegment,
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
        _ routeElementIdentifier: RouteSegment,
        animated: Bool,
        completionHandler: @escaping RoutingCompletionHandler) {

        callsToPopRouteSegment.append(
            (routeElement: routeElementIdentifier, animated: animated)
        )
        completionHandler()
    }

    func changeRouteSegment(
        _ from: RouteSegment,
        to: RouteSegment,
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

class FakeReducer: Reducer {
    func handleAction(action: Action, state: FakeAppState?) -> FakeAppState {
        return state ?? FakeAppState()
    }
}

struct AppReducer: Reducer {
    func handleAction(action: Action, state: FakeAppState?) -> FakeAppState {
        return FakeAppState(
            navigationState: NavigationReducer.handleAction(action, state: state?.navigationState)
        )
    }
}

class SwiftFlowRouterIntegrationTests: QuickSpec {

    override func spec() {

        describe("routing calls") {

            var store: Store<FakeAppState>!

            beforeEach {
                store = Store(reducer: CombinedReducer([AppReducer()]), state: FakeAppState())
            }

            describe("setup") {

                it("does not request the root view controller when no route is provided") {

                    class FakeRootRoutable: Routable {
                        var called = false

                        func pushRouteSegment(
                            _ route: RouteSegment,
                            animated: Bool,
                            completionHandler: @escaping RoutingCompletionHandler) -> Routable {
                            called = true
                            return MockRoutable()
                        }
                    }

                    let routable = FakeRootRoutable()
                    let _ = Router(store: store, rootRoutable: routable) { state in
                        state.navigationState
                    }

                    expect(routable.called).to(beFalse())
                }

                it("requests the root with identifier when an initial route is provided") {
                    let tabBarViewControllerSegment = MockRouteSegment()
                    store.dispatch(
                        SetRouteAction(
                            route: [tabBarViewControllerSegment]
                        )
                    )

                    class FakeRootRoutable: Routable {
                        var calledWithSegment: (RouteSegment?) -> Void

                        init(calledWithSegment: @escaping (RouteSegment?) -> Void) {
                            self.calledWithSegment = calledWithSegment
                        }

                        func pushRouteSegment(_ routeSegment: RouteSegment, animated: Bool, completionHandler: @escaping RoutingCompletionHandler) -> Routable {
                                calledWithSegment(routeSegment)

                                completionHandler()
                                return MockRoutable()
                        }

                    }

                    waitUntil(timeout: 2.0) { fullfill in
                        let rootRoutable = FakeRootRoutable { segment in
                            if let segment = segment, segment.instanceIdentifier == tabBarViewControllerSegment.instanceIdentifier {
                                fullfill()
                            }
                        }

                        let _ = Router(store: store, rootRoutable: rootRoutable) { state in
                            state.navigationState
                        }
                    }
                }

                it("calls push on the root for a route with two elements") {
                    let tabBarViewControllerSegment = MockRouteSegment()
                    let secondViewControllerSegment = MockRouteSegment()

                    store.dispatch(
                        SetRouteAction(
                            route: [tabBarViewControllerSegment, secondViewControllerSegment]
                        )
                    )

                    class FakeChildRoutable: Routable {
                        var calledWithSegment: (RouteSegment?) -> Void

                        init(calledWithSegment: @escaping (RouteSegment?) -> Void) {
                            self.calledWithSegment = calledWithSegment
                        }

                        func pushRouteSegment(_ routeElementIdentifier: RouteSegment, animated: Bool, completionHandler: @escaping RoutingCompletionHandler) -> Routable {
                                calledWithSegment(routeElementIdentifier)

                                completionHandler()
                                return MockRoutable()
                        }
                    }

                    waitUntil(timeout: 5.0) { completion in
                        let fakeChildRoutable = FakeChildRoutable() { segment in
                            if let segment = segment, segment.instanceIdentifier == secondViewControllerSegment.instanceIdentifier {
                                completion()
                            }
                        }

                        class FakeRootRoutable: Routable {
                            let injectedRoutable: Routable

                            init(injectedRoutable: Routable) {
                                self.injectedRoutable = injectedRoutable
                            }

                            func pushRouteSegment(_ routeElementIdentifier: RouteSegment, animated: Bool, completionHandler: @escaping RoutingCompletionHandler) -> Routable {
                                    completionHandler()
                                    return injectedRoutable
                            }
                        }

                        let _ = Router(store: store, rootRoutable:
                            FakeRootRoutable(injectedRoutable: fakeChildRoutable)) { state in
                                state.navigationState
                        }
                    }
                }

            }

        }


        describe("route specific data") {

            var store: Store<FakeAppState>!

            beforeEach {
                store = Store(reducer: AppReducer(), state: nil)
            }

            context("when setting route specific data") {

                struct MockRouteSegmentWithData: RouteSegment {
                    let instanceIdentifier: UUID = UUID()
                    let data: String
                }

                let mockSegment = MockRouteSegmentWithData(data: "UserID_10")

                beforeEach {
                    store.dispatch(SetRouteAction(route: [mockSegment]))
                }

                it("allows accessing the data when providing the expected type") {
                    guard let segment = store.state.navigationState.segmentWith(instanceIdentifier: mockSegment.instanceIdentifier) as? MockRouteSegmentWithData else {
                        return XCTFail("Could not find segment with instance identifier")
                    }

                    expect(segment.data).toEventually(equal("UserID_10"))
                }
                
            }
            
        }

        describe("configuring animated/unanimated navigation") {

            var store: Store<FakeAppState>!
            var mockRoutable: MockRoutable!
            var router: Router<FakeAppState>!
            let someRoute = MockRouteSegment()

            beforeEach {
                store = Store(reducer: AppReducer(), state: nil)
                mockRoutable = MockRoutable()
                router = Router(store: store, rootRoutable: mockRoutable) { state in
                    state.navigationState
                }

                // silence router not read warning, need to keep router alive via reference
                _ = router
            }

            context("when dispatching an animated route change") {
                beforeEach {
                    store.dispatch(SetRouteAction(route: [someRoute], animated: true))
                }

                it("calls routables asking for an animated presentation") {
                    expect(mockRoutable.callsToPushRouteSegment.last?.animated).toEventually(beTrue())
                }
            }

            context("when dispatching an unanimated route change") {
                beforeEach {
                    store.dispatch(SetRouteAction(route: [someRoute], animated: false))
                }

                it("calls routables asking for an animated presentation") {
                    expect(mockRoutable.callsToPushRouteSegment.last?.animated).toEventually(beFalse())
                }
            }

            context("when dispatching a default route change") {
                beforeEach {
                    store.dispatch(SetRouteAction(route: [someRoute]))
                }

                it("calls routables asking for an animated presentation") {
                    expect(mockRoutable.callsToPushRouteSegment.last?.animated).toEventually(beTrue())
                }
            }
        }

        describe("changing route without navigating") {
            var store: Store<FakeAppState>!
            var mockRoutable: MockRoutable!
            var router: Router<FakeAppState>!
            let someRoute = MockRouteSegment()

            beforeEach {
                store = Store(reducer: AppReducer(), state: nil)
                mockRoutable = MockRoutable()
                router = Router(store: store, rootRoutable: mockRoutable) { state in
                    state.navigationState
                }

                // silence router not read warning, need to keep router alive via reference
                _ = router
            }

            context("when dispatching a route change with navigation: false") {
                beforeEach {
                    store.dispatch(SetRouteAction(route: [someRoute], navigate: false))
                }

                it("does not call to push route segment") {
                    expect(mockRoutable.callsToPushRouteSegment).toEventually(beEmpty())
                }
            }
        }
    }
    
}
