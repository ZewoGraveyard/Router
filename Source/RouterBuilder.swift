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
    let basePath: String
    var routes: [Route] = []

    public var fallback: ResponderType = Responder { _ in
        return Response(status: .NotFound)
    }

    init(basePath: String) {
        self.basePath = basePath
    }
}

extension RouterBuilder {
    public func router(path: String, middleware: MiddlewareType..., router: RouterType) {
        let prefix = basePath + path

        let newRoutes = router.matcher.routes.map { route in
            return Route(
                methods: route.methods,
                path: prefix + route.path,
                middleware: middleware,
                responder: Responder { request in
                    var request = request

                    guard let path = request.path else {
                        return Response(status: .BadRequest)
                    }

                    let prefixLength = prefix.characters.count
                    request.uri.path = String(path.characters.dropFirst(prefixLength))
                    return try router.respond(request)
                }
            )
        }

        routes.appendContentsOf(newRoutes)
    }
}

extension RouterBuilder {
    public func fallback(middleware middleware: MiddlewareType..., respond: Respond) {
        fallback(middleware, responder: Responder(respond: respond))
    }

    public func fallback(middleware middleware: MiddlewareType..., responder: ResponderType) {
        fallback(middleware, responder: responder)
    }

    private func fallback(middleware: [MiddlewareType], responder: ResponderType) {
        fallback = middleware.intercept(responder)
    }
}

extension RouterBuilder {
    public func any(path: String, middleware: MiddlewareType..., respond: Respond) {
        any(path, middleware: middleware, responder: Responder(respond: respond))
    }

    public func any(path: String, middleware: MiddlewareType..., responder: ResponderType) {
        any(path, middleware: middleware, responder: responder)
    }

    private func any(path: String, middleware: [MiddlewareType], responder: ResponderType) {
        methods(Method.commonMethods, path: path, middleware: middleware, responder: responder)
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
        methods([.GET], path: path, middleware: middleware, responder: responder)
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
        methods([.POST], path: path, middleware: middleware, responder: responder)
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
        methods([.PUT], path: path, middleware: middleware, responder: responder)
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
        methods([.PATCH], path: path, middleware: middleware, responder: responder)
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
        methods([.DELETE], path: path, middleware: middleware, responder: responder)
    }
}

extension RouterBuilder {
    public func methods(m: Set<Method>, path: String, middleware: MiddlewareType..., respond: Respond) {
        methods(m, path: path, middleware: middleware, responder: Responder(respond: respond))
    }

    public func methods(m: Set<Method>, path: String, middleware: MiddlewareType..., responder: ResponderType) {
        methods(m, path: path, middleware: middleware, responder: responder)
    }

    private func methods(m: Set<Method>, path: String, middleware: [MiddlewareType], responder: ResponderType) {
        let route = Route(
            methods: m,
            path: basePath + path,
            middleware: middleware,
            responder: responder
        )
        routes.append(route)
    }
}