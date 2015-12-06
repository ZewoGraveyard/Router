HTTPRouter
==========

[![Swift 2.2](https://img.shields.io/badge/Swift-2.2-orange.svg?style=flat)](https://developer.apple.com/swift/)
[![Platforms Linux](https://img.shields.io/badge/Platforms-Linux-lightgray.svg?style=flat)](https://developer.apple.com/swift/)
[![License MIT](https://img.shields.io/badge/License-MIT-blue.svg?style=flat)](https://tldrlegal.com/license/mit-license)
[![Slack Status](https://zewo-slackin.herokuapp.com/badge.svg)](https://zewo-slackin.herokuapp.com)

**HTTPRouter** is an HTTP router for **Swift 2.2**.

## Features

- [x] URI path parameters
- [x] Route groups

## Dependencies

**HTTPRouter** is made of:

- [POSIXRegex](https://github.com/Zewo/POSIXRegex) - POSIX regex

## Usage

```swift
import HTTP
import HTTPRouter

let router = HTTPRouter { router in
    router.get("/users/:id") { request in
        let id = request.parameters["id"]
        return HTTPResponse(status: .OK)
    }
}
```

## Installation

- Install [`uri_parser`](https://github.com/Zewo/uri_parser)

```bash
$ git clone https://github.com/Zewo/uri_parser.git
$ cd uri_parser
$ make
$ dpkg -i uri_parser.deb
```

- Add `HTTPRouter` to your `Package.swift`

```swift
import PackageDescription

let package = Package(
	dependencies: [
		.Package(url: "https://github.com/Zewo/HTTPRouter.git", majorVersion: 0, minor: 1)
	]
)
```

## Community

[![Slack](http://s13.postimg.org/ybwy92ktf/Slack.png)](https://zewo-slackin.herokuapp.com)

Join us on [Slack](https://zewo-slackin.herokuapp.com).

License
-------

**HTTPRouter** is released under the MIT license. See LICENSE for details.
