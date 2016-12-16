//
//  SwiftFlowRouterUnitTests.swift
//  Meet
//
//  Created by Benjamin Encz on 12/2/15.
//  Copyright © 2015 DigiTales. All rights reserved.
//

import Quick
import Nimble

import ReSwift
@testable import ReSwiftRouter

struct MockRouteSegment: RouteSegment {
    let instanceIdentifier: UUID = UUID()
}

class ReSwiftRouterUnitTests: QuickSpec {

    // Used as test app state
    struct AppState: StateType {}

    override func spec() {
        describe("routing calls") {

            let tabBarViewControllerSegment = MockRouteSegment()
            let counterViewControllerSegment = MockRouteSegment()
            let statsViewControllerSegment = MockRouteSegment()
            let infoViewControllerSegment = MockRouteSegment()


            it("calculates transitions from an empty route to a multi segment route") {
                let oldRoute: [RouteSegment] = []
                let newRoute: [RouteSegment] = [tabBarViewControllerSegment, statsViewControllerSegment]

                let routingActions = Router<AppState>.routingActionsForTransitionFrom(oldRoute,
                    newRoute: newRoute)

                var action1Correct: Bool?
                var action2Correct: Bool?

                if case let RoutingActions.push(responsibleRoutableIndex, segmentToBePushed)
                    = routingActions[0] {

                        if responsibleRoutableIndex == 0
                            && segmentToBePushed.instanceIdentifier == tabBarViewControllerSegment.instanceIdentifier {
                                action1Correct = true
                        }
                }

                if case let RoutingActions.push(responsibleRoutableIndex, segmentToBePushed)
                    = routingActions[1] {

                        if responsibleRoutableIndex == 1
                            && segmentToBePushed.instanceIdentifier == statsViewControllerSegment.instanceIdentifier {
                            action2Correct = true
                        }
                }

                expect(routingActions).to(haveCount(2))
                expect(action1Correct).to(beTrue())
                expect(action2Correct).to(beTrue())
            }

            it("generates a Change action on the last common subroute") {
                let oldRoute = [tabBarViewControllerSegment, counterViewControllerSegment]
                let newRoute = [tabBarViewControllerSegment, statsViewControllerSegment]

                let routingActions = Router<AppState>.routingActionsForTransitionFrom(oldRoute,
                    newRoute: newRoute)

                var controllerIndex: Int?
                var toBeReplaced: RouteSegment?
                var new: RouteSegment?

                if case let RoutingActions.change(responsibleControllerIndex,
                    controllerToBeReplaced,
                    newController) = routingActions.first! {
                        controllerIndex = responsibleControllerIndex
                        toBeReplaced = controllerToBeReplaced
                        new = newController
                }

                expect(routingActions).to(haveCount(1))
                expect(controllerIndex).to(equal(1))
                expect(toBeReplaced!.instanceIdentifier).to(equal(counterViewControllerSegment.instanceIdentifier))
                expect(new!.instanceIdentifier).to(equal(statsViewControllerSegment.instanceIdentifier))
            }

            it("generates a Change action on the last common subroute, also for routes of different length") {
                let oldRoute = [tabBarViewControllerSegment, counterViewControllerSegment]
                let newRoute = [tabBarViewControllerSegment, statsViewControllerSegment,
                    infoViewControllerSegment]

                let routingActions = Router<AppState>.routingActionsForTransitionFrom(oldRoute,
                    newRoute: newRoute)

                var action1Correct: Bool?
                var action2Correct: Bool?

                if case let RoutingActions.change(responsibleRoutableIndex, segmentToBeReplaced,
                    newSegment)
                    = routingActions[0] {

                        if responsibleRoutableIndex == 1
                            && segmentToBeReplaced.instanceIdentifier == counterViewControllerSegment.instanceIdentifier
                            && newSegment.instanceIdentifier == statsViewControllerSegment.instanceIdentifier {
                                action1Correct = true
                        }
                }

                if case let RoutingActions.push(responsibleRoutableIndex, segmentToBePushed)
                    = routingActions[1] {

                        if responsibleRoutableIndex == 2
                            && segmentToBePushed.instanceIdentifier == infoViewControllerSegment.instanceIdentifier {

                                action2Correct = true
                        }
                }

                expect(routingActions).to(haveCount(2))
                expect(action1Correct).to(beTrue())
                expect(action2Correct).to(beTrue())
            }

            it("generates a Change action on root when root element changes") {
                let oldRoute = [tabBarViewControllerSegment]
                let newRoute = [statsViewControllerSegment]

                let routingActions = Router<AppState>.routingActionsForTransitionFrom(oldRoute,
                    newRoute: newRoute)

                var controllerIndex: Int?
                var toBeReplaced: RouteSegment?
                var new: RouteSegment?

                if case let RoutingActions.change(responsibleControllerIndex,
                    controllerToBeReplaced,
                    newController) = routingActions.first! {
                        controllerIndex = responsibleControllerIndex
                        toBeReplaced = controllerToBeReplaced
                        new = newController
                }

                expect(routingActions).to(haveCount(1))
                expect(controllerIndex).to(equal(0))
                expect(toBeReplaced!.instanceIdentifier).to(equal(tabBarViewControllerSegment.instanceIdentifier))
                expect(new!.instanceIdentifier).to(equal(statsViewControllerSegment.instanceIdentifier))
            }

            it("calculates no actions for transition from empty route to empty route") {
                let oldRoute: [RouteSegment] = []
                let newRoute: [RouteSegment] = []

                let routingActions = Router<AppState>.routingActionsForTransitionFrom(oldRoute,
                    newRoute: newRoute)

                expect(routingActions).to(haveCount(0))
            }

            it("calculates no actions for transitions between identical, non-empty routes") {
                let oldRoute = [tabBarViewControllerSegment, statsViewControllerSegment]
                let newRoute = [tabBarViewControllerSegment, statsViewControllerSegment]

                let routingActions = Router<AppState>.routingActionsForTransitionFrom(oldRoute,
                    newRoute: newRoute)

                expect(routingActions).to(haveCount(0))
            }

            it("calculates transitions with multiple pops") {
                let oldRoute = [tabBarViewControllerSegment, statsViewControllerSegment,
                    counterViewControllerSegment]
                let newRoute = [tabBarViewControllerSegment]

                let routingActions = Router<AppState>.routingActionsForTransitionFrom(oldRoute,
                    newRoute: newRoute)

                var action1Correct: Bool?
                var action2Correct: Bool?

                if case let RoutingActions.pop(responsibleRoutableIndex, segmentToBePopped)
                    = routingActions[0] {

                        if responsibleRoutableIndex == 2
                            && segmentToBePopped.instanceIdentifier == counterViewControllerSegment.instanceIdentifier {
                                action1Correct = true
                            }
                }

                if case let RoutingActions.pop(responsibleRoutableIndex, segmentToBePopped)
                    = routingActions[1] {

                        if responsibleRoutableIndex == 1
                            && segmentToBePopped.instanceIdentifier == statsViewControllerSegment.instanceIdentifier {
                                action2Correct = true
                        }
                }

                expect(action1Correct).to(beTrue())
                expect(action2Correct).to(beTrue())
                expect(routingActions).to(haveCount(2))
            }

            it("calculates transitions with multiple pushes") {
                let oldRoute = [tabBarViewControllerSegment]
                let newRoute = [tabBarViewControllerSegment, statsViewControllerSegment,
                    counterViewControllerSegment]

                let routingActions = Router<AppState>.routingActionsForTransitionFrom(oldRoute,
                    newRoute: newRoute)

                var action1Correct: Bool?
                var action2Correct: Bool?

                if case let RoutingActions.push(responsibleRoutableIndex, segmentToBePushed)
                    = routingActions[0] {

                        if responsibleRoutableIndex == 1
                            && segmentToBePushed.instanceIdentifier == statsViewControllerSegment.instanceIdentifier {
                                action1Correct = true
                        }
                }

                if case let RoutingActions.push(responsibleRoutableIndex, segmentToBePushed)
                    = routingActions[1] {

                        if responsibleRoutableIndex == 2
                            && segmentToBePushed.instanceIdentifier == counterViewControllerSegment.instanceIdentifier {
                                action2Correct = true
                        }
                }

                expect(action1Correct).to(beTrue())
                expect(action2Correct).to(beTrue())
                expect(routingActions).to(haveCount(2))
            }

        }

    }

}
