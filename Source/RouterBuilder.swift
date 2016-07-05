// RouterBuilder.swift
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

@_exported import HTTP

public class RouterBuilder {
    public let path: String
    public var routes: [Route] = []

    public var fallback: Responder = BasicResponder { _ in
        Response(status: .notFound)
    }

    public init(path: String) {
        self.path = path
    }
}

extension RouterBuilder {
    public func compose(_ router: RouterRepresentable) {
        compose(router: router)
    }
    
    public func compose(_ path: String = "", middleware: Middleware..., router representable: RouterRepresentable) {
        let router = representable.router
        let prefix = self.path + path

        let prefixPathComponentsCount = prefix.split(separator: "/").count

        for route in router.routes {
            for (method, _) in route.actions {
                addRoute(
                    method: method,
                    path: path + route.path,
                    middleware: middleware,
                    responder: BasicResponder { request in
                        var request = request

                        guard let path = request.path else {
                            return Response(status: .badRequest)
                        }

                        let requestPathComponents = path.split(separator: "/")
                        let shortenedRequestPathComponents = requestPathComponents.dropFirst(prefixPathComponentsCount)
                        let shortenedPath = "/" + shortenedRequestPathComponents.joined(separator: "/")

                        request.uri.path = shortenedPath
                        return try router.respond(to: request)
                    }
                )
            }
        }
    }
}

extension RouterBuilder {
    public func fallback(middleware: Middleware..., responder: Responder) {
        fallback(middleware: middleware, responder: responder)
    }

    public func fallback(middleware: Middleware..., respond: Respond) {
        fallback(middleware: middleware, responder: BasicResponder(respond))
    }

    private func fallback(middleware: [Middleware], responder: Responder) {
        fallback = middleware.chain(to: responder)
    }
}

extension RouterBuilder {
    public func get(_ path: String, middleware: Middleware..., responder: Responder) {
        get(path, middleware: middleware, responder: responder)
    }

    public func get(_ path: String, middleware: Middleware..., respond: Respond) {
        get(path, middleware: middleware, responder: BasicResponder(respond))
    }

    private func get(_ path: String, middleware: [Middleware], responder: Responder) {
        addRoute(method: .get, path: path, middleware: middleware, responder: responder)
    }
}

extension RouterBuilder {
    public func options(_ path: String, middleware: Middleware..., responder: Responder) {
        options(path, middleware: middleware, responder: responder)
    }

    public func options(_ path: String, middleware: Middleware..., respond: Respond) {
        options(path, middleware: middleware, responder: BasicResponder(respond))
    }

    private func options(_ path: String, middleware: [Middleware], responder: Responder) {
        addRoute(method: .options, path: path, middleware: middleware, responder: responder)
    }
}

extension RouterBuilder {
    public func post(_ path: String, middleware: Middleware..., responder: Responder) {
        post(path, middleware: middleware, responder: responder)
    }

    public func post(_ path: String, middleware: Middleware..., respond: Respond) {
        post(path, middleware: middleware, responder: BasicResponder(respond))
    }

    private func post(_ path: String, middleware: [Middleware], responder: Responder) {
        addRoute(method: .post, path: path, middleware: middleware, responder: responder)
    }
}

extension RouterBuilder {
    public func put(_ path: String, middleware: Middleware..., responder: Responder) {
        put(path, middleware: middleware, responder: responder)
    }

    public func put(_ path: String, middleware: Middleware..., respond: Respond) {
        put(path, middleware: middleware, responder: BasicResponder(respond))
    }

    private func put(_ path: String, middleware: [Middleware], responder: Responder) {
        addRoute(method: .put, path: path, middleware: middleware, responder: responder)
    }
}

extension RouterBuilder {
    public func patch(_ path: String, middleware: Middleware..., responder: Responder) {
        patch(path, middleware: middleware, responder: responder)
    }

    public func patch(_ path: String, middleware: Middleware..., respond: Respond) {
        patch(path, middleware: middleware, responder: BasicResponder(respond))
    }

    private func patch(_ path: String, middleware: [Middleware], responder: Responder) {
        addRoute(method: .patch, path: path, middleware: middleware, responder: responder)
    }
}

extension RouterBuilder {
    public func delete(_ path: String, middleware: Middleware..., responder: Responder) {
        delete(path, middleware: middleware, responder: responder)
    }

    public func delete(_ path: String, middleware: Middleware..., respond: Respond) {
        delete(path, middleware: middleware, responder: BasicResponder(respond))
    }

    private func delete(_ path: String, middleware: [Middleware], responder: Responder) {
        addRoute(method: .delete, path: path, middleware: middleware, responder: responder)
    }
}

extension RouterBuilder {
    public func methods(methods: Set<Method>, path: String, middleware: Middleware..., responder: Responder) {
        for method in methods {
            addRoute(method: method, path: path, middleware: middleware, responder: responder)
        }
    }

    public func methods(methods: Set<Method>, path: String, middleware: Middleware..., respond: Respond) {
        for method in methods {
            addRoute(method: method, path: path, middleware: middleware, responder: BasicResponder(respond))
        }
    }
}

extension RouterBuilder {
    public func fallback(_ path: String, middleware: Middleware..., responder: Responder) {
        addRouteFallback(path: path, middleware: middleware, responder: responder)
    }

    public func fallback(_ path: String, middleware: Middleware..., respond: Respond) {
        addRouteFallback(path: path, middleware: middleware, responder: BasicResponder(respond))
    }
}

extension RouterBuilder {
    public func addRouteFallback(path: String, middleware: [Middleware], responder: Responder) {
        let fallback = middleware.chain(to: responder)
        let routePath = self.path + path

        if let route = route(for: routePath) {
            route.fallback = fallback
        } else {
            let route = BasicRoute(path: routePath, fallback: fallback)
            routes.append(route)
        }
    }

    public func addRoute(method: Method, path: String, middleware: [Middleware], responder: Responder) {
        let action = middleware.chain(to: responder)
        let routePath = self.path + path

        if let route = route(for: routePath) {
            route.addAction(method: method, action: action)
        } else {
            let route = BasicRoute(path: routePath, actions: [method: action])
            routes.append(route)
        }
    }

    private func route(for path: String) -> BasicRoute? {
        for route in routes where route.path == path {
            return route as? BasicRoute
        }
        return nil
    }
}

// TODO: Move this into the RouteMatcher protocol
//extension Router {
//    public func splitPathIntoComponents(_ path: String) -> [String] {
//        return path.split(separator: "/")
//    }
//
//    public func mergePathComponents(_ components: [String]) -> String {
//        return "/" + components.joined(separator: "/")
//    }
//}
