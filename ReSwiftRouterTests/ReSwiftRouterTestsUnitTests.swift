//
//  SwiftFlowRouterUnitTests.swift
//  Meet
//
//  Created by Benjamin Encz on 12/2/15.
//  Copyright © 2015 ReSwift Community. All rights reserved.
//

import Quick
import Nimble

import ReSwift
@testable import ReSwiftRouter

class ReSwiftRouterUnitTests: QuickSpec {

    // Used as test app state
    struct AppState {}

    override func spec() {
        describe("routing calls") {

            let tabBarViewControllerElement = "TabBarViewController"
            let counterViewControllerElement = "CounterViewController"
            let statsViewControllerElement = "StatsViewController"
            let infoViewControllerElement = "InfoViewController"

            it("calculates transitions from an empty route to a multi element route") {
                let oldRoute: Route = []
                let newRoute = [tabBarViewControllerElement, statsViewControllerElement]

                let routingActions = Router<AppState>.routingActionsForTransition(from: oldRoute,
                                                                                  to: newRoute)

                var action1Correct: Bool?
                var action2Correct: Bool?

                if case let RoutingActions.push(responsibleRoutableIndex, elementToBePushed)
                    = routingActions[0] {

                        if responsibleRoutableIndex == 0
                            && elementToBePushed == tabBarViewControllerElement {
                                action1Correct = true
                        }
                }

                if case let RoutingActions.push(responsibleRoutableIndex, elementToBePushed)
                    = routingActions[1] {

                        if responsibleRoutableIndex == 1
                            && elementToBePushed == statsViewControllerElement {
                            action2Correct = true
                        }
                }

                expect(routingActions).to(haveCount(2))
                expect(action1Correct).to(beTrue())
                expect(action2Correct).to(beTrue())
            }

            it("generates a Change on the last common subroute for routes of same length") {
                
                let oldRoute = [tabBarViewControllerElement, counterViewControllerElement]
                let newRoute = [tabBarViewControllerElement, statsViewControllerElement]

              let routingActions = Router<AppState>.routingActionsForTransition(from: oldRoute,
                                                                                to: newRoute)

                var controllerIndex: Int?
                var toBeReplaced: RouteElement?
                var new: RouteElement?

                if case let RoutingActions.change(responsibleControllerIndex,
                    controllerToBeReplaced,
                    newController) = routingActions.first! {
                        controllerIndex = responsibleControllerIndex
                        toBeReplaced = controllerToBeReplaced
                        new = newController
                }

                expect(routingActions).to(haveCount(1))
                expect(controllerIndex).to(equal(1))
                expect(toBeReplaced).to(equal(counterViewControllerElement))
                expect(new).to(equal(statsViewControllerElement))
            }

            it("generates a Change on the last common subroute when new route is longer than the old route") {
                let oldRoute = [tabBarViewControllerElement, counterViewControllerElement]
                let newRoute = [tabBarViewControllerElement, statsViewControllerElement,
                    infoViewControllerElement]

                let routingActions = Router<AppState>.routingActionsForTransition(from: oldRoute,
                                                                                  to: newRoute)

                var action1Correct: Bool?
                var action2Correct: Bool?

                if case let RoutingActions.change(responsibleRoutableIndex, elementToBeReplaced,
                    newElement)
                    = routingActions[0] {

                        if responsibleRoutableIndex == 1
                            && elementToBeReplaced == counterViewControllerElement
                            && newElement == statsViewControllerElement{
                                action1Correct = true
                        }
                }

                if case let RoutingActions.push(responsibleRoutableIndex, elementToBePushed)
                    = routingActions[1] {

                        if responsibleRoutableIndex == 2
                            && elementToBePushed == infoViewControllerElement {

                                action2Correct = true
                        }
                }

                expect(routingActions).to(haveCount(2))
                expect(action1Correct).to(beTrue())
                expect(action2Correct).to(beTrue())
            }
            
            it("generates a Change on the last common subroute when the new route is shorter than the old route") {
                let oldRoute = [tabBarViewControllerElement, counterViewControllerElement,infoViewControllerElement]
                let newRoute = [tabBarViewControllerElement, statsViewControllerElement]
                
                let routingActions = Router<AppState>.routingActionsForTransition(from: oldRoute,
                                                                                  to: newRoute)
                
                var action1Correct: Bool?
                var action2Correct: Bool?
                
                if case let RoutingActions.pop(responsibleRoutableIndex, elementToBePopped)
                    = routingActions[0] {
                    
                    if responsibleRoutableIndex == 2
                        && elementToBePopped == infoViewControllerElement {
                        
                        action1Correct = true
                    }
                }
                
                if case let RoutingActions.change(responsibleRoutableIndex, elementToBeReplaced,
                                                  newElement)
                    = routingActions[1] {
                    
                    if responsibleRoutableIndex == 1
                        && elementToBeReplaced == counterViewControllerElement
                        && newElement == statsViewControllerElement{
                        action2Correct = true
                    }
                }
                
                expect(routingActions).to(haveCount(2))
                expect(action1Correct).to(beTrue())
                expect(action2Correct).to(beTrue())
            }

            it("generates a Change action on root when root element changes") {
                let oldRoute = [tabBarViewControllerElement]
                let newRoute = [statsViewControllerElement]

                let routingActions = Router<AppState>.routingActionsForTransition(from: oldRoute,
                                                                                  to: newRoute)

                var controllerIndex: Int?
                var toBeReplaced: RouteElement?
                var new: RouteElement?

                if case let RoutingActions.change(responsibleControllerIndex,
                    controllerToBeReplaced,
                    newController) = routingActions.first! {
                        controllerIndex = responsibleControllerIndex
                        toBeReplaced = controllerToBeReplaced
                        new = newController
                }

                expect(routingActions).to(haveCount(1))
                expect(controllerIndex).to(equal(0))
                expect(toBeReplaced).to(equal(tabBarViewControllerElement))
                expect(new).to(equal(statsViewControllerElement))
            }

            it("calculates no actions for transition from empty route to empty route") {
                let oldRoute: Route = []
                let newRoute: Route = []

                let routingActions = Router<AppState>.routingActionsForTransition(from: oldRoute,
                                                                                  to: newRoute)

                expect(routingActions).to(haveCount(0))
            }

            it("calculates no actions for transitions between identical, non-empty routes") {
                let oldRoute = [tabBarViewControllerElement, statsViewControllerElement]
                let newRoute = [tabBarViewControllerElement, statsViewControllerElement]

                let routingActions = Router<AppState>.routingActionsForTransition(from: oldRoute,
                                                                                  to: newRoute)

                expect(routingActions).to(haveCount(0))
            }

            it("calculates transitions with multiple pops") {
                let oldRoute = [tabBarViewControllerElement, statsViewControllerElement,
                    counterViewControllerElement]
                let newRoute = [tabBarViewControllerElement]

                let routingActions = Router<AppState>.routingActionsForTransition(from: oldRoute,
                                                                                  to: newRoute)

                var action1Correct: Bool?
                var action2Correct: Bool?

                if case let RoutingActions.pop(responsibleRoutableIndex, elementToBePopped)
                    = routingActions[0] {

                        if responsibleRoutableIndex == 2
                            && elementToBePopped == counterViewControllerElement {
                                action1Correct = true
                            }
                }

                if case let RoutingActions.pop(responsibleRoutableIndex, elementToBePopped)
                    = routingActions[1] {

                        if responsibleRoutableIndex == 1
                            && elementToBePopped == statsViewControllerElement {
                                action2Correct = true
                        }
                }

                expect(action1Correct).to(beTrue())
                expect(action2Correct).to(beTrue())
                expect(routingActions).to(haveCount(2))
            }

            it("calculates transitions with multiple pushes") {
                let oldRoute = [tabBarViewControllerElement]
                let newRoute = [tabBarViewControllerElement, statsViewControllerElement,
                    counterViewControllerElement]

                let routingActions = Router<AppState>.routingActionsForTransition(from: oldRoute,
                                                                                  to: newRoute)

                var action1Correct: Bool?
                var action2Correct: Bool?

                if case let RoutingActions.push(responsibleRoutableIndex, elementToBePushed)
                    = routingActions[0] {

                        if responsibleRoutableIndex == 1
                            && elementToBePushed == statsViewControllerElement {
                                action1Correct = true
                        }
                }

                if case let RoutingActions.push(responsibleRoutableIndex, elementToBePushed)
                    = routingActions[1] {

                        if responsibleRoutableIndex == 2
                            && elementToBePushed == counterViewControllerElement {
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
