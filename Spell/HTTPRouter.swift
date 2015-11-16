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
    struct HTTPRoute : HTTPResponderType {
        let path: String
        let methods: Set<HTTPMethod>
        let respond: HTTPContext -> Void

        private let parameterKeys: [String]
        private let regularExpression: Regex

        init(path: String, methods: Set<HTTPMethod>, respond: HTTPContext -> Void) {
            self.path = path
            self.methods = methods
            self.respond = respond

            let parameterRegularExpression = try! Regex(pattern: ":([[:alnum:]]+)")
            let pattern = parameterRegularExpression.replace(path, withTemplate: "([[:alnum:]]+)")

            self.parameterKeys = parameterRegularExpression.groups(path)
            self.regularExpression = try! Regex(pattern: "^" + pattern + "$")
        }

        func matchesRequest(request: HTTPRequest) -> Bool {
            return regularExpression.matches(request.uri.path!) && methods.contains(request.method)
        }

        func respond(request: HTTPRequest, completion: HTTPResponse -> Void) {
            let values = self.regularExpression.groups(request.uri.path!)
            var context = HTTPContext(request: request, completion: completion)

            for (index, key) in parameterKeys.enumerate() {
                context.parameters[key] = values[index]
            }
            
            respond(context)
        }
    }

    public final class HTTPRouterBuilder {
        let basePath: String
        var routes: [HTTPRoute] = []

        init(basePath: String) {
            self.basePath = basePath
        }

        var fallback: HTTPContext -> Void = { context in
            context.send(HTTPResponse(statusCode: 404, reasonPhrase: "Not Found"))
        }

        public func group(basePath: String, build: (group: HTTPRouterBuilder) -> Void) {
            let groupBuilder = HTTPRouterBuilder(basePath: basePath)
            build(group: groupBuilder)

            for route in groupBuilder.routes {
                routes.append(HTTPRoute(path: self.basePath + route.path, methods: route.methods, respond: route.respond))
            }
        }

        public func fallback(fallback: HTTPContext -> Void) {
            self.fallback = fallback
        }

        public func fallback(responder: HTTPContextResponderType) {
            fallback(responder.respond)
        }

        public func any(path: String, respond: HTTPContext -> Void) {
            let route = HTTPRoute(
                path: basePath + path,
                methods: [
                    .GET,
                    .POST,
                    .PUT,
                    .PATCH,
                    .DELETE
                ],
                respond: respond
            )

            routes.append(route)
        }

        public func any(path: String, responder: HTTPContextResponderType) {
            any(path, respond: responder.respond)
        }

        public func get(path: String, respond: HTTPContext -> Void) {
            let route = HTTPRoute(
                path: basePath + path,
                methods: [.GET],
                respond: respond
            )

            routes.append(route)
        }

        public func get(path: String, responder: HTTPContextResponderType) {
            get(path, respond: responder.respond)
        }

        public func post(path: String, respond: HTTPContext -> Void) {
            let route = HTTPRoute(
                path: basePath + path,
                methods: [.POST],
                respond: respond
            )

            routes.append(route)
        }

        public func post(path: String, responder: HTTPContextResponderType) {
            post(path, respond: responder.respond)
        }

        public func put(path: String, respond: HTTPContext -> Void) {
            let route = HTTPRoute(
                path: basePath + path,
                methods: [.PUT],
                respond: respond
            )

            routes.append(route)
        }

        public func put(path: String, responder: HTTPContextResponderType) {
            put(path, respond: responder.respond)
        }

        public func patch(path: String, respond: HTTPContext -> Void) {
            let route = HTTPRoute(
                path: basePath + path,
                methods: [.PATCH],
                respond: respond
            )

            routes.append(route)
        }

        public func patch(path: String, responder: HTTPContextResponderType) {
            patch(path, respond: responder.respond)
        }

        public func delete(path: String, respond: HTTPContext -> Void) {
            let route = HTTPRoute(
                path: basePath + path,
                methods: [.DELETE],
                respond: respond
            )
            
            routes.append(route)
        }

        public func delete(path: String, responder: HTTPContextResponderType) {
            delete(path, respond: responder.respond)
        }

        // TODO: Use regex to validate the path string.
        public func resources<T: HTTPResourceType>(path: String, resources: T) {
            get(basePath + path, respond: resources.index)
            post(basePath + path, respond: resources.create)
            get(basePath + path + "/:id", respond: resources.show)
            put(basePath + path + "/:id", respond: resources.update)
            patch(basePath + path + "/:id", respond: resources.update)
            delete(basePath + path + "/:id", respond: resources.destroy)
        }

        // TODO: Use regex to validate the path string.
        public func resource<T: HTTPResourceType>(path: String, resources: T) {
            get(basePath + path, respond: resources.index)
            post(basePath + path, respond: resources.create)
            put(basePath + path, respond: resources.update)
            patch(basePath + path, respond: resources.update)
            delete(basePath + path, respond: resources.destroy)
        }
    }

    let routes: [HTTPRoute]
    let fallback: HTTPContext -> Void

    public init(basePath: String = "", build: (router: HTTPRouterBuilder) -> Void) {
        let routerBuilder = HTTPRouterBuilder(basePath: basePath)
        build(router: routerBuilder)

        fallback = routerBuilder.fallback
        routes = routerBuilder.routes
    }

    public func respond(request: HTTPRequest, completion: HTTPResponse -> Void) {
        for route in routes {
            if route.matchesRequest(request) {
                route.respond(request, completion: completion)
                return
            }
        }
        fallback(HTTPContext(request: request, completion: completion))
    }
}