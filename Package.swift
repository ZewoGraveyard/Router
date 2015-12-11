import PackageDescription

let package = Package(
	name: "HTTPRouter",
	dependencies: [
        .Package(url: "https://github.com/Zewo/POSIXRegex.git", majorVersion: 0, minor: 1),
        .Package(url: "https://github.com/Zewo/HTTP.git", majorVersion: 0, minor: 1),
        .Package(url: "https://github.com/Zewo/HTTPMiddleware.git", majorVersion: 0, minor: 1)
	]
)
