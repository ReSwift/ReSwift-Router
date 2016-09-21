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

class ReSwiftRouterUnitTests: QuickSpec {

    // Used as test app state
    struct AppState: StateType {}

    override func spec() {
        describe("routing calls") {

            let tabBarViewControllerIdentifier = "TabBarViewController"
            let counterViewControllerIdentifier = "CounterViewController"
            let statsViewControllerIdentifier = "StatsViewController"
            let infoViewControllerIdentifier = "InfoViewController"

            it("calculates transitions from an empty route to a multi segment route") {
                let oldRoute: Route = []
                let newRoute = [tabBarViewControllerIdentifier, statsViewControllerIdentifier]

                let routingActions = Router<AppState>.routingActionsForTransitionFrom(oldRoute,
                    newRoute: newRoute)

                var action1Correct: Bool?
                var action2Correct: Bool?

                if case let RoutingActions.push(responsibleRoutableIndex, segmentToBePushed)
                    = routingActions[0] {

                        if responsibleRoutableIndex == 0
                            && segmentToBePushed == tabBarViewControllerIdentifier {
                                action1Correct = true
                        }
                }

                if case let RoutingActions.push(responsibleRoutableIndex, segmentToBePushed)
                    = routingActions[1] {

                        if responsibleRoutableIndex == 1
                            && segmentToBePushed == statsViewControllerIdentifier {
                            action2Correct = true
                        }
                }

                expect(routingActions).to(haveCount(2))
                expect(action1Correct).to(beTrue())
                expect(action2Correct).to(beTrue())
            }

            it("generates a Change action on the last common subroute") {
                let oldRoute = [tabBarViewControllerIdentifier, counterViewControllerIdentifier]
                let newRoute = [tabBarViewControllerIdentifier, statsViewControllerIdentifier]

                let routingActions = Router<AppState>.routingActionsForTransitionFrom(oldRoute,
                    newRoute: newRoute)

                var controllerIndex: Int?
                var toBeReplaced: RouteElementIdentifier?
                var new: RouteElementIdentifier?

                if case let RoutingActions.change(responsibleControllerIndex,
                    controllerToBeReplaced,
                    newController) = routingActions.first! {
                        controllerIndex = responsibleControllerIndex
                        toBeReplaced = controllerToBeReplaced
                        new = newController
                }

                expect(routingActions).to(haveCount(1))
                expect(controllerIndex).to(equal(1))
                expect(toBeReplaced).to(equal(counterViewControllerIdentifier))
                expect(new).to(equal(statsViewControllerIdentifier))
            }

            it("generates a Change action on the last common subroute, also for routes of different length") {
                let oldRoute = [tabBarViewControllerIdentifier, counterViewControllerIdentifier]
                let newRoute = [tabBarViewControllerIdentifier, statsViewControllerIdentifier,
                    infoViewControllerIdentifier]

                let routingActions = Router<AppState>.routingActionsForTransitionFrom(oldRoute,
                    newRoute: newRoute)

                var action1Correct: Bool?
                var action2Correct: Bool?

                if case let RoutingActions.change(responsibleRoutableIndex, segmentToBeReplaced,
                    newSegment)
                    = routingActions[0] {

                        if responsibleRoutableIndex == 1
                            && segmentToBeReplaced == counterViewControllerIdentifier
                            && newSegment == statsViewControllerIdentifier{
                                action1Correct = true
                        }
                }

                if case let RoutingActions.push(responsibleRoutableIndex, segmentToBePushed)
                    = routingActions[1] {

                        if responsibleRoutableIndex == 2
                            && segmentToBePushed == infoViewControllerIdentifier {

                                action2Correct = true
                        }
                }

                expect(routingActions).to(haveCount(2))
                expect(action1Correct).to(beTrue())
                expect(action2Correct).to(beTrue())
            }

            it("generates a Change action on root when root element changes") {
                let oldRoute = [tabBarViewControllerIdentifier]
                let newRoute = [statsViewControllerIdentifier]

                let routingActions = Router<AppState>.routingActionsForTransitionFrom(oldRoute,
                    newRoute: newRoute)

                var controllerIndex: Int?
                var toBeReplaced: RouteElementIdentifier?
                var new: RouteElementIdentifier?

                if case let RoutingActions.change(responsibleControllerIndex,
                    controllerToBeReplaced,
                    newController) = routingActions.first! {
                        controllerIndex = responsibleControllerIndex
                        toBeReplaced = controllerToBeReplaced
                        new = newController
                }

                expect(routingActions).to(haveCount(1))
                expect(controllerIndex).to(equal(0))
                expect(toBeReplaced).to(equal(tabBarViewControllerIdentifier))
                expect(new).to(equal(statsViewControllerIdentifier))
            }

            it("calculates no actions for transition from empty route to empty route") {
                let oldRoute: Route = []
                let newRoute: Route = []

                let routingActions = Router<AppState>.routingActionsForTransitionFrom(oldRoute,
                    newRoute: newRoute)

                expect(routingActions).to(haveCount(0))
            }

            it("calculates no actions for transitions between identical, non-empty routes") {
                let oldRoute = [tabBarViewControllerIdentifier, statsViewControllerIdentifier]
                let newRoute = [tabBarViewControllerIdentifier, statsViewControllerIdentifier]

                let routingActions = Router<AppState>.routingActionsForTransitionFrom(oldRoute,
                    newRoute: newRoute)

                expect(routingActions).to(haveCount(0))
            }

            it("calculates transitions with multiple pops") {
                let oldRoute = [tabBarViewControllerIdentifier, statsViewControllerIdentifier,
                    counterViewControllerIdentifier]
                let newRoute = [tabBarViewControllerIdentifier]

                let routingActions = Router<AppState>.routingActionsForTransitionFrom(oldRoute,
                    newRoute: newRoute)

                var action1Correct: Bool?
                var action2Correct: Bool?

                if case let RoutingActions.pop(responsibleRoutableIndex, segmentToBePopped)
                    = routingActions[0] {

                        if responsibleRoutableIndex == 2
                            && segmentToBePopped == counterViewControllerIdentifier {
                                action1Correct = true
                            }
                }

                if case let RoutingActions.pop(responsibleRoutableIndex, segmentToBePopped)
                    = routingActions[1] {

                        if responsibleRoutableIndex == 1
                            && segmentToBePopped == statsViewControllerIdentifier {
                                action2Correct = true
                        }
                }

                expect(action1Correct).to(beTrue())
                expect(action2Correct).to(beTrue())
                expect(routingActions).to(haveCount(2))
            }

            it("calculates transitions with multiple pushes") {
                let oldRoute = [tabBarViewControllerIdentifier]
                let newRoute = [tabBarViewControllerIdentifier, statsViewControllerIdentifier,
                    counterViewControllerIdentifier]

                let routingActions = Router<AppState>.routingActionsForTransitionFrom(oldRoute,
                    newRoute: newRoute)

                var action1Correct: Bool?
                var action2Correct: Bool?

                if case let RoutingActions.push(responsibleRoutableIndex, segmentToBePushed)
                    = routingActions[0] {

                        if responsibleRoutableIndex == 1
                            && segmentToBePushed == statsViewControllerIdentifier {
                                action1Correct = true
                        }
                }

                if case let RoutingActions.push(responsibleRoutableIndex, segmentToBePushed)
                    = routingActions[1] {

                        if responsibleRoutableIndex == 2
                            && segmentToBePushed == counterViewControllerIdentifier {
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
