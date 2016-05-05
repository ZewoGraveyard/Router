# Router
[![Swift 3.0](https://img.shields.io/badge/Swift-3.0-orange.svg?style=flat)](https://developer.apple.com/swift/) [![Platforms Mac & Linux](https://img.shields.io/badge/Platforms-Linux-lightgray.svg?style=flat)](https://developer.apple.com/swift/) [![License MIT](https://img.shields.io/badge/License-MIT-blue.svg?style=flat)](https://tldrlegal.com/license/mit-license) [![Slack Status](https://zewo-slackin.herokuapp.com/badge.svg)](http://slack.zewo.io)

## Overview
**Router** is a highly extensibly and customizable HTTP router.

## Usage
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

### Extending `RouterBuilder`
TODO: Write this

### Composing Routers
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
