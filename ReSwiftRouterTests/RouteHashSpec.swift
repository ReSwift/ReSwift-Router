//
//  RouteHashTests.swift
//  ReSwiftRouter
//
//  Created by Benji Encz on 7/16/16.
//  Copyright © 2016 Benjamin Encz. All rights reserved.
//

import ReSwiftRouter
import Quick
import Nimble

class RouteHashTests: QuickSpec {

    override func spec() {

        describe("when two route hashs are initialized with the same elements") {

            var routeHash1: RouteHash!
            var routeHash2: RouteHash!

            beforeEach {
                routeHash1 = RouteHash(route: ["part1", "part2"])
                routeHash2 = RouteHash(route: ["part1", "part2"])
            }

            it("both hashs are considered equal") {
                expect(routeHash1).to(equal(routeHash2))
            }

        }

        describe("when two route hashs are initialized with different elements") {

            var routeHash1: RouteHash!
            var routeHash2: RouteHash!

            beforeEach {
                routeHash1 = RouteHash(route: ["part1", "part2"])
                routeHash2 = RouteHash(route: ["part3", "part4"])
            }

            it("they are considered unequal") {
                expect(routeHash1).toNot(equal(routeHash2))
            }

        }

    }

}
