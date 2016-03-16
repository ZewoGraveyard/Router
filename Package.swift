import PackageDescription

let package = Package(
    name: "Router",
    dependencies: [
        .Package(url: "https://github.com/Zewo/RegexRouteMatcher.git", majorVersion: 0, minor: 4),
        .Package(url: "https://github.com/Zewo/TrieRouteMatcher.git", majorVersion: 0, minor: 4),
    ]
)
