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

There is a lot of repetition going on there. Not only are we prefixing each route with `/api/v1` or `/api/v2`, but we are also repeating `/thing` and `/object`.

This is where `route.compose` comes in to save the day! What we're going to do is extract the `/api`, `/v1`, and `/v2` routers and compose them all together.

Lets start from top. Our new base router is going to look something like this:

```swift
let mainRouter = Router { route in
    route.compose("/api", router: apiRouter)
}
```

Great! Now the `mainRouter` is going to be forwarding all of its requests to `apiRouter`.

`apiRouter` looks similar...

```swift
let apiRouter = Router { route in
    route.compose("/v1", router: v1Router)
    route.compose("/v2", router: v2Router)
}
```

Now `v1Router` and `v2Router` is where the bulk of the routes actually are. Let's do `v1Router` first.

```swift
let v1Router = Router { route
    route.get("/") { ... }
    route.get("/thing") { ... }
    route.get("/thing/:id") { ... }
    route.put("/thing/:id") { ... }
}
```

Notice how the router is totally encapsulated and has no knowledge of routes other than its own.

Since `v2Router` is the same thing, it's not worth a separate code snippet. However, we're not done yet! 

For the sake of the example, lets assume that `thing` and `object` are identical, and the _only_ difference between them is that their name changed from version 1 to version 2. To avoid that code duplication, lets create a new `objectRouter` that both `v1Router` and `v2Router` would use.

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

While this is obviously a contrived example, the pattern of reusing routers in this way is very powerful. Also, composing multiple routers together allows for better project organization (possibly across multiple files or modules).

### Extending `RouterBuilder`
TODO: Write this

### Injecting Custom Matchers
TODO: Write this

### Middleware
TODO: Write this

## Community
[![Slack](http://s13.postimg.org/ybwy92ktf/Slack.png)](http://slack.zewo.io)

Join us on [Slack](http://slack.zewo.io).

## License
**Router** is released under the MIT license. See LICENSE for details.