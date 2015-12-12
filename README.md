Router
==========

[![Swift 2.2](https://img.shields.io/badge/Swift-2.2-orange.svg?style=flat)](https://developer.apple.com/swift/)
[![Platforms Linux](https://img.shields.io/badge/Platforms-Linux-lightgray.svg?style=flat)](https://developer.apple.com/swift/)
[![License MIT](https://img.shields.io/badge/License-MIT-blue.svg?style=flat)](https://tldrlegal.com/license/mit-license)
[![Slack Status](https://zewo-slackin.herokuapp.com/badge.svg)](https://zewo-slackin.herokuapp.com)

HTTP router for **Swift 2.2**.

## Features

- [x] URI path parameters
- [x] Route groups

## Usage

```swift
import HTTP
import Router

let router = Router { router in
    router.get("/users/:id") { request in
        let id = request.parameters["id"]
        return HTTPResponse(status: .OK)
    }
}
```

## Installation

- Install [`uri_parser`](https://github.com/Zewo/uri_parser)

### Linux

```bash
$ sudo add-apt-repository 'deb [trusted=yes] http://apt.zewo.io/deb ./'
$ sudo apt-get update
$ sudo apt-get install uri-parser
```

### OS X

```bash
$ brew tap zewo/tap
$ brew udpate
$ brew install uri_parser
```

- Add `Router` to your `Package.swift`

```swift
import PackageDescription

let package = Package(
	dependencies: [
		.Package(url: "https://github.com/Zewo/Router.git", majorVersion: 0, minor: 1)
	]
)
```

## Community

[![Slack](http://s13.postimg.org/ybwy92ktf/Slack.png)](https://zewo-slackin.herokuapp.com)

Join us on [Slack](https://zewo-slackin.herokuapp.com).

License
-------

**Router** is released under the MIT license. See LICENSE for details.
