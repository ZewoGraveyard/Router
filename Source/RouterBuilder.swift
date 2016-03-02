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

public final class RouterBuilder {
    let path: String
    var routes: [RouteType] = []

    var fallbackAction = Action(
        responder: Responder { _ in Response(status: .NotFound) }
    )

    init(path: String = "") {
        self.path = path
    }
}

extension RouterBuilder {
    public func compose(path: String, middleware: MiddlewareType..., router: RouterType) {
        let prefix = self.path + path
        let prefixPathComponentsCount = router.splitPathIntoComponents(prefix).count

        for route in router.routes {
            for (method, _) in route.actions {
                addRoute(
                    method: method,
                    path: path + route.path,
                    middleware: middleware,
                    responder: Responder { request in
                        var request = request

                        guard let path = request.path else {
                            return Response(status: .BadRequest)
                        }

                        let requestPathComponents = router.splitPathIntoComponents(path)
                        let shortenedRequestPathComponents = requestPathComponents.dropFirst(prefixPathComponentsCount)
                        let shortenedPath = router.mergePathComponents(Array(shortenedRequestPathComponents))

                        request.uri.path = shortenedPath
                        return try router.respond(request)
                    }
                )
            }
        }
    }
}

extension RouterBuilder {
    public var fallback: ResponderType {
        get {
            return Responder(respond: fallbackAction.respond)
        }

        set {
            self.fallbackAction = Action(
                responder: Responder { _ in Response(status: .NotFound) }
            )
        }
    }

    public func fallback(middleware middleware: MiddlewareType..., respond: Respond) {
        fallback(middleware, responder: Responder(respond: respond))
    }

    public func fallback(middleware middleware: MiddlewareType..., responder: ResponderType) {
        fallback(middleware, responder: responder)
    }

    private func fallback(middleware: [MiddlewareType], responder: ResponderType) {
        fallbackAction = Action(
            middleware:  middleware,
            responder: responder
        )
    }
}

extension RouterBuilder {
    public func get(path: String, middleware: MiddlewareType..., respond: Respond) {
        get(path, middleware: middleware, responder: Responder(respond: respond))
    }

    public func get(path: String, middleware: MiddlewareType..., responder: ResponderType) {
        get(path, middleware: middleware, responder: responder)
    }

    private func get(path: String, middleware: [MiddlewareType], responder: ResponderType) {
        addRoute(method: .GET, path: path, middleware: middleware, responder: responder)
    }
}

extension RouterBuilder {
    public func post(path: String, middleware: MiddlewareType..., respond: Respond) {
        post(path, middleware: middleware, responder: Responder(respond: respond))
    }

    public func post(path: String, middleware: MiddlewareType..., responder: ResponderType) {
        post(path, middleware: middleware, responder: responder)
    }

    private func post(path: String, middleware: [MiddlewareType], responder: ResponderType) {
        addRoute(method: .POST, path: path, middleware: middleware, responder: responder)
    }
}

extension RouterBuilder {
    public func put(path: String, middleware: MiddlewareType..., respond: Respond) {
        put(path, middleware: middleware, responder: Responder(respond: respond))
    }

    public func put(path: String, middleware: MiddlewareType..., responder: ResponderType) {
        put(path, middleware: middleware, responder: responder)
    }

    private func put(path: String, middleware: [MiddlewareType], responder: ResponderType) {
        addRoute(method: .PUT, path: path, middleware: middleware, responder: responder)
    }
}

extension RouterBuilder {
    public func patch(path: String, middleware: MiddlewareType..., respond: Respond) {
        patch(path, middleware: middleware, responder: Responder(respond: respond))
    }

    public func patch(path: String, middleware: MiddlewareType..., responder: ResponderType) {
        patch(path, middleware: middleware, responder: responder)
    }

    private func patch(path: String, middleware: [MiddlewareType], responder: ResponderType) {
        addRoute(method: .PATCH, path: path, middleware: middleware, responder: responder)
    }
}

extension RouterBuilder {
    public func delete(path: String, middleware: MiddlewareType..., respond: Respond) {
        delete(path, middleware: middleware, responder: Responder(respond: respond))
    }

    public func delete(path: String, middleware: MiddlewareType..., responder: ResponderType) {
        delete(path, middleware: middleware, responder: responder)
    }

    private func delete(path: String, middleware: [MiddlewareType], responder: ResponderType) {
        addRoute(method: .DELETE, path: path, middleware: middleware, responder: responder)
    }
}

extension RouterBuilder {
    public func methods(methods: Set<Method>, path: String, middleware: MiddlewareType..., respond: Respond) {
        for method in methods {
            addRoute(method: method, path: path, middleware: middleware, responder: Responder(respond: respond))
        }
    }

    public func methods(methods: Set<Method>, path: String, middleware: MiddlewareType..., responder: ResponderType) {
        for method in methods {
            addRoute(method: method, path: path, middleware: middleware, responder: responder)
        }
    }
}

extension RouterBuilder {
    public func fallback(path: String, middleware: MiddlewareType..., respond: Respond) {
        fallback(middleware, responder: Responder(respond: respond))
    }

    public func fallback(path: String, middleware: MiddlewareType..., responder: ResponderType) {
        fallback(middleware, responder: responder)
    }
}

extension RouterBuilder {
    private func fallback(path: String, middleware: [MiddlewareType], responder: ResponderType) {
        let fallback = Action(middleware: middleware, responder: responder)
        let finalPath = self.path + path

        if let route = routeFor(finalPath) {
            route.fallback = fallback
        } else {
            createRoute(path: finalPath, fallback: fallback)
        }
    }

    private func addRoute(method method: Method, path: String, middleware: [MiddlewareType], responder: ResponderType) {
        let action = Action(middleware: middleware, responder: responder)
        let finalPath = self.path + path

        if let route = routeFor(finalPath) {
            route.addAction(method: method, action: action)
        } else {
            createRoute(path: finalPath, method: method, action: action)
        }
    }

    private func routeFor(path: String) -> Route? {
        for route in routes where route.path == path {
            return route as? Route
        }
        return nil
    }

    private func createRoute(path path: String, method: Method, action: Action) {
        let route = Route(
            path: path,
            actions: [method: action]
        )
        routes.append(route)
    }

    private func createRoute(path path: String, fallback: Action) {
        let route = Route(
            path: path,
            fallback: fallback
        )
        routes.append(route)
    }
}

public final class Route: RouteType {
    public let path: String
    public var actions: [Method: Action]
    public var fallback: Action

    init(path: String, actions: [Method: Action] = [:], fallback: Action = Route.defaultFallback) {
        self.path = path
        self.actions = actions
        self.fallback = fallback
    }

    func addAction(method method: Method, action: Action) {
        actions[method] = action
    }

    static var defaultFallback: Action {
        return Action(
            responder: Responder { _ in Response(status: .MethodNotAllowed) }
        )
    }
}
