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
        let innerRouter = Router { route in
            route.get("/:location/of/zewo") { request in
                return Response(status: .ok)
            }
        }

        let router = Router("/:greeting") { route in
            route.compose("/:adjective", router: innerRouter)
        }

        let request = try! Request(method: .get, uri: "/hello/beautiful/world/of/zewo")
        let response = try! router.respond(to: request)
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
        let response1 = try mainRouter.respond(to: request1)
        let response2 = try mainRouter.respond(to: request2)

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
    static var allTests: [(String, (RouterTests) -> () throws -> Void)] {
        return [
            ("testRouterBuilder", testRouterBuilder),
            ("testNestedRoutersWithParameters", testNestedRoutersWithParameters),
            ("testNestedRouterWithSamePaths", testNestedRouterWithSamePaths)
        ]
    }
}
