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
        let responder = Responder { _ in Response() }

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
                    return Response(status: .OK)
                }
            })
        }

        let request = try! Request(method: .GET, uri: "/hello/beautiful/world/of/zewo")
        let response = try! router.respond(request)
        XCTAssertEqual(response.statusCode, 200)
    }
}
