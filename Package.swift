import PackageDescription

let package = Package(
	name: "Router",
	dependencies: [
        .Package(url: "https://github.com/RikEnde/HTTP.git", majorVersion: 0, minor: 1),
        .Package(url: "https://github.com/Zewo/CURIParser.git", majorVersion: 0, minor: 1),
	]
)
