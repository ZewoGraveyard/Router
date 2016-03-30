// Router.swift
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

@_exported import TrieRouteMatcher
@_exported import RegexRouteMatcher

public struct Router: HTTP.Router {
    public let middleware: [Middleware]
    public let routes: [Route]
    public let fallback: Responder
    public let matcher: RouteMatcher

    public init(_ path: String = "", middleware: Middleware..., matcher: RouteMatcher.Type = TrieRouteMatcher.self, build: (route: RouterBuilder) -> Void) {
        let builder = RouterBuilder(path: path)
        build(route: builder)
        self.middleware = middleware
        self.routes = builder.routes
        self.fallback = builder.fallback
        self.matcher = matcher.init(routes: builder.routes)
    }

    public func match(request: Request) -> Route? {
        return matcher.match(request)
    }
}

extension Router {
    public func respond(request: Request) throws -> Response {
        let responder = match(request) ?? fallback
        return try middleware.intercept(responder).respond(request)
    }
}