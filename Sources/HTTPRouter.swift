// HTTPRouter.swift
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

import HTTP
import POSIXRegex

public struct HTTPRouter: HTTPResponderType {
    struct HTTPRoute: HTTPResponderType {
        let path: String
        let methods: Set<HTTPMethod>
        let routeRespond: HTTPRequest throws -> HTTPResponse

        private let parameterKeys: [String]
        private let regularExpression: Regex

        init(path: String, methods: Set<HTTPMethod>, routeRespond: HTTPRequest throws -> HTTPResponse) {
            self.path = path
            self.methods = methods
            self.routeRespond = routeRespond

            let parameterRegularExpression = try! Regex(pattern: ":([[:alnum:]]+)")
            let pattern = parameterRegularExpression.replace(path, withTemplate: "([[:alnum:]]+)")

            self.parameterKeys = parameterRegularExpression.groups(path)
            self.regularExpression = try! Regex(pattern: "^" + pattern + "$")
        }

        func matchesRequest(request: HTTPRequest) -> Bool {
            return regularExpression.matches(request.uri.path!) && methods.contains(request.method)
        }

        func respond(request: HTTPRequest) throws -> HTTPResponse {
            var request = request
            let values = self.regularExpression.groups(request.uri.path!)

            for (index, key) in parameterKeys.enumerate() {
                request.parameters[key] = values[index]
            }
            
            return try routeRespond(request)
        }
    }

    public final class HTTPRouterBuilder {
        let basePath: String
        var routes: [HTTPRoute] = []

        init(basePath: String) {
            self.basePath = basePath
        }

        var fallback: HTTPRequest throws -> HTTPResponse = { request in
            return HTTPResponse(statusCode: 404, reasonPhrase: "Not Found")
        }

        public func group(basePath: String, build: (group: HTTPRouterBuilder) -> Void) {
            let builder = HTTPRouterBuilder(basePath: basePath)
            build(group: builder)

            routes = builder.routes.map { route in
                HTTPRoute(
                    path: self.basePath + route.path,
                    methods: route.methods,
                    routeRespond: route.routeRespond
                )
            }
        }

        public func fallback(fallback: HTTPRequest throws -> HTTPResponse) {
            self.fallback = fallback
        }

        public func fallback(responder: HTTPResponderType) {
            fallback(responder.respond)
        }

        public func any(path: String, _ respond: HTTPRequest throws -> HTTPResponse) {
            let route = HTTPRoute(
                path: basePath + path,
                methods: [
                    .GET,
                    .POST,
                    .PUT,
                    .PATCH,
                    .DELETE
                ],
                routeRespond: respond
            )

            routes.append(route)
        }

        public func any(path: String, _ responder: HTTPResponderType) {
            any(path, responder.respond)
        }

        public func get(path: String, _ respond: HTTPRequest throws -> HTTPResponse) {
            let route = HTTPRoute(
                path: basePath + path,
                methods: [.GET],
                routeRespond: respond
            )

            routes.append(route)
        }

        public func get(path: String, _ responder: HTTPResponderType) {
            get(path, responder.respond)
        }

        public func post(path: String, _ respond: HTTPRequest throws -> HTTPResponse) {
            let route = HTTPRoute(
                path: basePath + path,
                methods: [.POST],
                routeRespond: respond
            )

            routes.append(route)
        }

        public func post(path: String, _ responder: HTTPResponderType) {
            post(path, responder.respond)
        }

        public func put(path: String, _ respond: HTTPRequest throws -> HTTPResponse) {
            let route = HTTPRoute(
                path: basePath + path,
                methods: [.PUT],
                routeRespond: respond
            )

            routes.append(route)
        }

        public func put(path: String, _ responder: HTTPResponderType) {
            put(path, responder.respond)
        }

        public func patch(path: String, _ respond: HTTPRequest throws -> HTTPResponse) {
            let route = HTTPRoute(
                path: basePath + path,
                methods: [.PATCH],
                routeRespond: respond
            )

            routes.append(route)
        }

        public func patch(path: String, _ responder: HTTPResponderType) {
            patch(path, responder.respond)
        }

        public func delete(path: String, _ respond: HTTPRequest throws -> HTTPResponse) {
            let route = HTTPRoute(
                path: basePath + path,
                methods: [.DELETE],
                routeRespond: respond
            )
            
            routes.append(route)
        }

        public func delete(path: String, _ responder: HTTPResponderType) {
            delete(path, responder.respond)
        }
    }

    let routes: [HTTPRoute]
    let fallback: HTTPRequest throws -> HTTPResponse

    public init(basePath: String = "", build: (router: HTTPRouterBuilder) -> Void) {
        let builder = HTTPRouterBuilder(basePath: basePath)
        build(router: builder)

        fallback = builder.fallback
        routes = builder.routes
    }

    public func respond(request: HTTPRequest) throws -> HTTPResponse {
        for route in routes {
            if route.matchesRequest(request) {
                return try route.respond(request)
            }
        }
        return try fallback(request)
    }
}