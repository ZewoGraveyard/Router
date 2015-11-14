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

public struct HTTPRouter : HTTPResponderType {
    private var routes: [HTTPRoute]
    private var fallback: HTTPContext -> Void

    public func respond(request: HTTPRequest, completion: HTTPResponse -> Void) {
        for route in routes {
            if route.matchesRequest(request) {
                route.respond(request, completion: completion)
                return
            }
        }
        fallback(HTTPContext(request: request, completion: completion))
    }

    public init(basePath: String = "", _ build: (router: HTTPRouterBuilder) -> Void) {
        let routerBuilder = HTTPRouterBuilder(basePath: basePath)
        build(router: routerBuilder)

        fallback = routerBuilder.fallback
        routes = routerBuilder.routes
    }

    public final class HTTPRouterBuilder {
        private let basePath: String
        private var routes: [HTTPRoute] = []

        init(basePath: String) {
            self.basePath = basePath
        }

        var fallback: HTTPContext -> Void = { context in
            context.send(HTTPResponse(status: .NotFound))
        }

        public func group(basePath: String, _ build: (group: HTTPRouterBuilder) -> Void) {
            let groupBuilder = HTTPRouterBuilder(basePath: basePath)
            build(group: groupBuilder)

            for route in groupBuilder.routes {
                routes.append(HTTPRoute(path: self.basePath + route.path, methods: route.methods, respond: route.respond))
            }
        }

        public func fallback(f: HTTPContext -> Void) {
            self.fallback = f
        }

        public func any(path: String, _ respond: HTTPContext -> Void) {
            let route = HTTPRoute(
                path: basePath + path,
                methods: [.GET, .POST, .PUT, .PATCH, .DELETE],
                respond: respond
            )

            routes.append(route)
        }

        public func get(path: String, _ respond: HTTPContext -> Void) {
            let route = HTTPRoute(
                path: basePath + path,
                methods: [.GET],
                respond: respond
            )

            routes.append(route)
        }

        public func post(path: String, _ respond: HTTPContext -> Void) {
            let route = HTTPRoute(
                path: basePath + path,
                methods: [.POST],
                respond: respond
            )

            routes.append(route)
        }

        public func put(path: String, _ respond: HTTPContext -> Void) {
            let route = HTTPRoute(
                path: basePath + path,
                methods: [.PUT],
                respond: respond
            )

            routes.append(route)
        }

        public func patch(path: String, _ respond: HTTPContext -> Void) {
            let route = HTTPRoute(
                path: basePath + path,
                methods: [.PATCH],
                respond: respond
            )

            routes.append(route)
        }

        public func delete(path: String, _ respond: HTTPContext -> Void) {
            let route = HTTPRoute(
                path: basePath + path,
                methods: [.DELETE],
                respond: respond
            )

            routes.append(route)
        }
    }
}