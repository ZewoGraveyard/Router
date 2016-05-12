# Router
[![Swift 3.0](https://img.shields.io/badge/Swift-3.0-orange.svg?style=flat)](https://developer.apple.com/swift/) [![Platforms Mac & Linux](https://img.shields.io/badge/Platforms-Linux-lightgray.svg?style=flat)](https://developer.apple.com/swift/) [![License MIT](https://img.shields.io/badge/License-MIT-blue.svg?style=flat)](https://tldrlegal.com/license/mit-license) [![Slack Status](https://zewo-slackin.herokuapp.com/badge.svg)](http://slack.zewo.io)

## Overview
**Router** is a highly extensibly and customizable HTTP router.

## Usage / Tutorial
### The Basics
A simple 'hello world' example looks like so:

```swift
let router = Router { route in
    route.get("/hello") { request in
        return Response(body: "Hello, Zewo!")
    }
}
```

The router can then be piped into anything that takes an [S4-compatible `Responder`](https://github.com/open-swift/S4). For example, using the [`HTTPServer`](https://github.com/VeniceX/HTTPServer) module:

```swift
let server = Server(responder: router)
server.start()
```

### Path Parameters
Often times, you want your paths to be dynamic so that you can embed information without using query parameters. With `Router`, any route component that starts with a colon (`:`) is considered a parameter.

A parameter component will match any string and allow you to access its value through the request. That is, the route `/hello/:object` will match `/hello/world`, `/hello/123`, and so on. However, it will not match just `/hello` or `/hello/world/123`.

In your route handler, you can extract the value of the path parameter through the `pathParemeters` property on `Request` like so:

```swift
route.get("/hello/:object") { request in
    guard let object = request.pathParameters["object"] else {
        return Response(status: .internalServerError)
    }
    return Response(body: "Hello, \(object)!")
}
```

The above route will not only respond to `/hello/world` with `"Hello, world!"`, but also to `/hello/there` with `"Hello, there!"` and to `/hello/123` with `"Hello, 123!"` (and so on).

There is no limit to how many path parameters can be in a url. For example, the following route, which is defined as `/:greeting/:location`, will respond to `/hey/there` with `"hey, there!"` as expected.

```swift
route.get("/:greeting/:location") { request in
    guard let
        greeting = request.pathParameters["greeting"],
        location = request.pathParameters["location"]
        else {
            return Response(status: .internalServerError)
        }
    return Response(body: "\(greeting), \(location)!")
}
```

You can also use a wildcard (`*`) in your routes, which matches _all_ paths beginning with the given path parameters preceding the wildcard. For example, `/static/*` will match `/static/script.js` and `/static/scripts/script.js` and so on, but not just `/static`.

In case of conflicting routes, the default matcher ([TrieRouteMatcher](https://github.com/Zewo/TrieRouteMatcher)) will rank them based on the following order of priority:
1. static
2. parameter
3. wildcard

That way, with routes `/hello/world`, `/hello/:greeting`, and `/hello/*`, `/hello/world` would get matched by only the static route and not by the parameter or wildcard routes.

### Composing Routers
A router can quickly become huge or have a lot of repetitive routes. To address this issue, `Router` comes with the ability to compose routers together.

Take this router, for example:

```swift
let router = Router { route in
    // prefixed with /v1/
    route.get("/api/v1") { ... }
    route.get("/api/v1/thing") { ... }
    route.get("/api/v1/thing/:id") { ... }
    route.put("/api/v1/thing/:id") { ... }
    // prefixed with /v2/
    route.get("/api/v2") { ... }
    route.get("/api/v2/object") { ... }
    route.get("/api/v2/object/:id") { ... }
    route.put("/api/v2/object/:id") { ... }
}
```

There is a lot of repetition going on there. Not only are we prefixing each route with `/api/v1` or `/api/v2`, but we are also repeating `/thing` and `/object`. This is exactly the kind of situation where you should use `route.compose`. What we're going to do is extract the `/api`, `/v1`, and `/v2` routers and compose them all together into one big router.

Lets start from top. Our new base router is going to look something like this:

```swift
let mainRouter = Router { route in
    route.compose("/api", router: apiRouter)
}
```

The syntax for composing routers is really simple. With that code, the `mainRouter` is now going to be forwarding all of its requests that start with `/api` to `apiRouter`.

`apiRouter` is essentially the same thing.

```swift
let apiRouter = Router { route in
    route.compose("/v1", router: v1Router)
    route.compose("/v2", router: v2Router)
}
```

`v1Router` and `v2Router` are where the bulk of the routes are going to be. Notice how the routers are totally encapsulated and have no knowledge of how they're going to be embedded in other routers.

```swift
let v1Router = Router { route
    route.get("/") { ... }
    route.get("/thing") { ... }
    route.get("/thing/:id") { ... }
    route.put("/thing/:id") { ... }
}
let v2Router = Router { route in
    route.get("/") { ... }
    route.get("/object") { ... }
    route.get("/object/:id") { ... }
    route.put("/object/:id") { ... }    
}
```

For the sake of the example, lets assume that `thing` and `object` are identical, and the _only_ difference between them is that their name changed from version 1 to version 2. To avoid that code duplication, lets create a new `objectRouter` that both `v1Router` and `v2Router` can use under different paths.

```swift
let objectRouter = Router { route in
    route.get("/") { ... }
    route.get("/:id") { ... }
    route.put("/:id") { ... }
}
```

Wonderful! Now, `v1Router` and `v2Router` can both use `objectRouter` and get rid of the unnecessary code duplication.

```swift
let v1Router = Router { route in
    route.get("/") { ... }
    route.compose("/thing", router: objectRouter)
}
let v2Router = Router { route in
    route.get("/") { ... }
    route.compose("/object", router: objectRouter)
}
```

While this is a fairly contrived example, the pattern of reusing routers in this way is very powerful. Also, composing multiple routers together allows for better project organization, which is very important for bigger applications.

### Extending `RouterBuilder`
One of the ideals of Zewo is to provide highly-extensible components, and `Router` is a great example of this. The way `Router` is implemented behind the scenes is through a class called `RouterBuilder`, which is passed in to the closure you provide when instantiating the `Router`.

By default, `RouterBuilder` has support for the following operations:
- get
- options
- post
- put
- patch
- delete
- methods
- fallback
- addRoute
- compose

Let's pretend that you were looking through your codebase and found that the following pattern was being repeated a lot:

```swift
route.get("/:id") { request in
    guard let id = request.pathParameters["id"] else {
        return Response(status: .badRequest)
    }
    // do something with id
    return Response(...)
}
```

What we want is to overload the `get` method and create an API that looks something like this:

```swift
route.get { request, id in
    // do something with id
    return Response(...)
}
```

Now that we have a target, let's get started. The only modification we're really making here is adding another parameter to the handler. To understand how to do this, let me break down the current current decleration of `get`:

```swift
get(
  _ path: String, // the path (ex: "/hello") (removed)
  middleware: Middleware...,  // middleware (unchanged)
  respond: Respond // typealias for Request throws -> Response (modified)
)
```

Our method is going to be removing the path parameter altogether (it will always be "/:id"), and modifying the `respond` parameter to be `(Request, String) throws -> Response`.

```swift
get(
    middleware: Middleware...,
    respond: (Request, String) throws -> Response
)
```

The implementation for this is going to be really simple - we're just wrapping the `get` method that is already provided for us.

```swift
func get(...) {
    // call the default `get` method
    get("/:id", middleware: middleware) { request in
        // get the id parameter
        guard let id = request.pathParameters["id"] else {
            return Response(status: .internalServerError)
        }
        // call the responder with the request and id
        let response = try respond(request, id)
        // return the result of that responder
        return response
    }
}
```

It's that simple! All we have to do now is put the code in an extension to `RouterBuilder` and the code snippet at the beginning of the section will work as expected.

### Injecting Custom Matchers
In some (rare) cases, you may want to add functionality to the matching part of the router. For example, what if you want to denote parameters with `<param>` instead of `:param`, or split on `.` instead of `/` (like slack's api)? Or, more likely, what if you want to match routes based on a regular expression instead of something static? To allow this kind of behavior, you can inject your own `RouteMatcher` into the `Router` upon initialization, like so:

```swift
let router = Router(matcher: SomeSpecialMatcher.Self)
```

By default, the matcher is set to [TrieRouteMatcher](https://github.com/Zewo/TrieRouteMatcher.git), which is a high-performance matcher that supports all of the basic route matching functionality (parameters, wildcards, etc.).

To make your own matcher, you simply have to conform to the `RouteMatcher` protocol.

```swift
public protocol RouteMatcher {
    var routes: [Route] { get }
    init(routes: [Route])
    func match(_ request: Request) -> Route?
}
```

A really simple matcher which only matches exact paths would look something like this:

```swift
public struct SimpleRouteMatcher {
    let routes: [Route]
    init(routes: [Route]) {
        self.routes = routes
    }
    func match(_ request: Request) -> Route? {
        for route in routes {
            if route.path == request.path {
                return route
            }
        }
        return nil
    }
}
```

You can then use the route matcher in your own routers!

```swift
Router(matcher: SimpleRouteMatcher.self) { route in
    route.get("/hello") { request in
        return Response(body: "Hello, world!")
    }
}
```

### Middleware
TODO: Write this

## Community
[![Slack](http://s13.postimg.org/ybwy92ktf/Slack.png)](http://slack.zewo.io)

Join us on [Slack](http://slack.zewo.io).

## License
**Router** is released under the MIT license. See LICENSE for details.
