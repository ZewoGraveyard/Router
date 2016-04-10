# Router
[![Swift 3.0](https://img.shields.io/badge/Swift-3.0-orange.svg?style=flat)](https://developer.apple.com/swift/) [![Platforms Mac & Linux](https://img.shields.io/badge/Platforms-Linux-lightgray.svg?style=flat)](https://developer.apple.com/swift/) [![License MIT](https://img.shields.io/badge/License-MIT-blue.svg?style=flat)](https://tldrlegal.com/license/mit-license) [![Slack Status](https://zewo-slackin.herokuapp.com/badge.svg)](http://slack.zewo.io)

## Overview
**Router** is a highly extensibly and customizable HTTP router.

## Usage

```swift
let router = Router { route in
    route.get("/:greeting") { request in
        guard let greeting = request.pathParameters["greeting"] else {
            return Response(status: .internalServerError)
        }
        return Response(body: "Hello, \(greeting)!")
    }
}
```

## Community
[![Slack](http://s13.postimg.org/ybwy92ktf/Slack.png)](http://slack.zewo.io)

Join us on [Slack](http://slack.zewo.io).

## License
**Router** is released under the MIT license. See LICENSE for details.
