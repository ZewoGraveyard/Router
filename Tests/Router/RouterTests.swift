// RouterTests.swift
//
// The MIT License (MIT)
//
// Copyright (c) 2015 Zewo
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import XCTest
@testable import Router

class RouterTests: XCTestCase {
    func testRouterBuilder() {
        let responder = BasicResponder { _ in Response() }

        let builder = RouterBuilder()
        builder.get("/users", responder: responder)
        builder.post("/users", responder: responder)

        XCTAssertEqual(builder.routes.count, 1)
        XCTAssertEqual(builder.routes.first?.actions.count, 2)
    }

    func testNestedRoutersWithParameters() {
        let router = Router("/:greeting") { route in
            route.compose("/:adjective", router: Router { route in
                route.get("/:location/of/zewo") { request in
                    return Response(status: .ok)
                }
            })
        }

        let request = try! Request(method: .get, uri: "/hello/beautiful/world/of/zewo")
        let response = try! router.respond(request)
        XCTAssertEqual(response.statusCode, 200)
    }

    func testNestedRouterWithSamePaths() throws {

        let router1 = Router { route in
            route.get("/path") { _ in return Response(body: "route 1") }
        }
        let router2 = Router { route in
            route.post("/path") { _ in return Response(body: "route 2") }
        }
        let mainRouter = Router { route in
            route.compose(router: router1)
            route.compose(router: router2)
        }

        let request1 = try Request(method: .get, uri: "/path")
        let request2 = try Request(method: .post, uri: "/path")
        let response1 = try mainRouter.respond(request1)
        let response2 = try mainRouter.respond(request2)

        XCTAssertEqual(response1.status.statusCode, 200)
        XCTAssertEqual(response2.status.statusCode, 200)

        guard
            case let .buffer(body1) = response1.body,
            case let .buffer(body2) = response2.body
            else {
            return
        }

        XCTAssertEqual(body1, "route 1")
        XCTAssertEqual(body2, "route 2")
    }
}

extension RouterTests {
    static var allTests: [(String, RouterTests -> () throws -> Void)] {
        return [
            ("testRouterBuilder", testRouterBuilder),
            ("testNestedRoutersWithParameters", testNestedRoutersWithParameters),
            ("testNestedRouterWithSamePaths", testNestedRouterWithSamePaths)
        ]
    }
}
