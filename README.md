# Router
[![Swift][swift-badge]][swift-url]
[![Zewo][zewo-badge]][zewo-url]
[![Platform][platform-badge]][platform-url]
[![License][mit-badge]][mit-url]
[![Slack][slack-badge]][slack-url]
[![Travis][travis-badge]][travis-url]
[![Codebeat][codebeat-badge]][codebeat-url]

## Overview
**Router** is a highly extensibly and customizable HTTP router.

## Installation
```swift
import PackageDescription

let package = Package(
    name: "HelloZewo"
    dependencies: [
        .Package(url: "https://github.com/Zewo/Router.git", majorVersion: 0, minor: 7),
    ]
)
```

## Usage / Tutorial
### The Basics
A simple 'hello world' example looks like so:

```swift
import Router

let router = Router { route in
    route.get("/hello") { request in
        return Response(body: "Hello, Zewo!")
    }
}
```

The router can then be passed to anything that takes an [S4-compatible `Responder`](https://github.com/open-swift/S4). A `Responder` is just something that takes a `Request` and returns a `Response`. `Router`'s role as a `Responder` is to take that `Request` and pass it along to the route that matches the path.

The most common use of a route would be to handle requests from an HTTPServer. Using the [`HTTPServer`](https://github.com/VeniceX/HTTPServer) module, for example, we can do just that:

```swift
let server = Server(responder: router)
server.start()
```

If you were to execute the above code and go to `localhost:8080/hello` in your browser, you would see a plaintext response of "Hello, Zewo!".

### Path Parameters
Often times, you want your paths to be dynamic so that you can embed information without using query parameters. With `Router`, any route component that starts with a colon (`:`) is considered a parameter.

A parameter component will match any string and let it take its place. That is, the route `/hello/:object` will match `/hello/world` and `/hello/123`. However, it will not match `/hello` or `/hello/world/123`.

#### Extracting Path Parameter Values
In your route handler, you can extract the value of the path parameter through the `pathParameters` property on `Request` like so:

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

#### Wildcard
You can also use a wildcard (`*`) in your routes, which matches _all_ paths beginning with the given path parameters preceding the wildcard. For example, `/static/*` will match `/static/script.js` and `/static/scripts/script.js` and so on, but not just `/static`.

#### Route Conflicts

In case of conflicting routes, the default matcher ([TrieRouteMatcher](https://github.com/Zewo/TrieRouteMatcher)) will rank them based on the following order of priority:
1. static
2. parameter
3. wildcard

That way, with routes `/hello/world`, `/hello/:greeting`, and `/hello/*`, `/hello/world` would get matched by only the static route and not by the parameter or wildcard routes.

### Applying and creating Middleware
Middleware is a powerful part of the Zewo application structure. `Router`, along with all `Responder`s, can have middleware applied to them. We will create a middleware which will catch errors in the responder chain and respond with a customizable error page. Zewo already provides this for you by the name of [Recovery Middleware](https://github.com/Zewo/RecoveryMiddleware), but as an exercise we will re-implement it anyway.

This is the ideal syntax that we want to end up with:

```swift
enum CustomError: ErrorProtocol {
    case badId
}
let recovery = RecoveryMiddleware { error in
    switch error {
        case CustomError.badId:
            return Response(body: "The id doesn't exist!")
        default:
            throw error // dont handle, rethrow it
    }
}
let router = Router(middleware: recovery) { route in
    route.get("/:id") { route in
        guard let
          id = request.pathParameters["id"]
          where id != "-1"
          else {
            throw CustomError.badId
        }
        // do something with id...
        return Response(...)
    }
}
```

The definition of middleware actually comes from [Open Swift](https://github.com/open-swift/S4/blob/master/Sources/Middleware.swift), which is a standard organization that Zewo and several other server-side-swift players have started. The `Middleware` protocol:

```swift
public protocol Middleware {
    func respond(to request: Request, chainingTo next: Responder) throws -> Response
}
```

So, here is the starting boilerplate for our middleware.

```swift
struct RecoveryMiddleware {
    let recover: (ErrorProtocol) throws -> Response

    public func respond(to request: Request, chainingTo next: Responder) throws -> Response {
        // middleware code goes here
    }
}
```

Let's study the required `respond` method. We are passed in the request and the next responder in the responder chain. This gives us a lot of flexibility: we can modify the request before we pass it to the responder, and modify the response that the responder generates. We can also catch any errors that the responder may throw:

```swift
func respond(to request: Request, chainingTo next: Responder) throws -> Response {
    // we don't modify the request beforehand
    do {
        // return the next responder, catch possible errors
        return try next.respond(to: request)
    } catch {
        // pass the error to the `recover` method
        return try self.recover(error)
    }
}
```

That's it! It's very simple and powerful. We have now achieved the behavior that was showcased in the first code block.

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

Let's start from top. Our new base router is going to look something like this:

```swift
let mainRouter = Router { route in
    route.compose("/api", router: apiRouter)
}
```

With the `route.compose` call, the `mainRouter` is now going to be forwarding all of its requests that start with `/api` to `apiRouter`.

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
One of the objectives of Zewo is to provide highly-extensible components, and `Router` is a great example of this. The way `Router` is implemented behind the scenes is through a class called `RouterBuilder`, which is passed in to the closure you provide when instantiating the `Router`.

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

Assume that you were looking through your codebase and found that the following pattern was being repeated:

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

Now that we have a target, it's time to get started. The only modification we're really making here is adding another parameter to the handler. To understand how to do this, let's break down the current current decleration of `get`:

```swift
get(
  _ path: String, // the path (ex: "/hello") (removed)
  middleware: Middleware...,  // middleware (unchanged)
  respond: Respond // typealias for Request throws -> Response (modified)
)
```

Our method is going to be removing the path parameter altogether (it will always be `/:id`), and modifying the `respond` parameter to be `(Request, String) throws -> Response`.

```swift
get(
    middleware: Middleware...,
    respond: (Request, String) throws -> Response
)
```

The implementation for this is going to be really simple - we're just wrapping around the `get` method that is already provided for us.

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

That's it! All we have to do now is put the code in an extension to `RouterBuilder` and the code snippet at the beginning of the section will work as expected.

### Injecting Custom Matchers
In some (rare) cases, you may want to add functionality to the matching component of the router. For example, what if you want to denote parameters with `<param>` instead of `:param`, or split on `.` instead of `/` (like Slack's API)? Or, more likely, what if you want to match routes based on a regular expression instead of something static? To allow this kind of behavior, you can inject your own `RouteMatcher` into the `Router` upon initialization, like so:

```swift
let router = Router(matcher: SomeSpecialMatcher.Self)
```

By default, the matcher is set to [TrieRouteMatcher](https://github.com/Zewo/TrieRouteMatcher.git), which is a high-performance matcher that supports all of the basic route matching functionality (parameters, wildcards, etc.).

To make your own matcher, you must conform to the `RouteMatcher` protocol.

```swift
public protocol RouteMatcher {
    var routes: [Route] { get }
    init(routes: [Route])
    func match(_ request: Request) -> Route?
}
```

A basic matcher which only matches exact paths would look something like this:

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

## Support

If you need any help you can join our [Slack](http://slack.zewo.io) and go to the **#help** channel. Or you can create a Github [issue](https://github.com/Zewo/Zewo/issues/new) in our main repository. When stating your issue be sure to add enough details, specify what module is causing the problem and reproduction steps.

## Community
[![Slack][slack-image]][slack-url]

The entire Zewo code base is licensed under MIT. By contributing to Zewo you are contributing to an open and engaged community of brilliant Swift programmers. Join us on [Slack](http://slack.zewo.io) to get to know us!

## License
This project is released under the MIT license. See [LICENSE](LICENSE) for details.

[swift-badge]: https://img.shields.io/badge/Swift-3.0-orange.svg?style=flat
[swift-url]: https://swift.org
[zewo-badge]: https://img.shields.io/badge/Zewo-0.7-FF7565.svg?style=flat
[zewo-url]: http://zewo.io
[platform-badge]: https://img.shields.io/badge/Platforms-OS%20X%20--%20Linux-lightgray.svg?style=flat
[platform-url]: https://swift.org
[mit-badge]: https://img.shields.io/badge/License-MIT-blue.svg?style=flat
[mit-url]: https://tldrlegal.com/license/mit-license
[slack-image]: http://s13.postimg.org/ybwy92ktf/Slack.png
[slack-badge]: https://zewo-slackin.herokuapp.com/badge.svg
[slack-url]: http://slack.zewo.io
[travis-badge]: https://travis-ci.org/Zewo/Router.svg?branch=master
[travis-url]: https://travis-ci.org/Zewo/Router
[codebeat-badge]: https://codebeat.co/badges/e6e7bdb7-155e-4d8e-909c-eec6e3c647f4
[codebeat-url]: https://codebeat.co/projects/github-com-zewo-router
