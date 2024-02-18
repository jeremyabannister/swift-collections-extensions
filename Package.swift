// swift-tools-version: 5.9

///
import PackageDescription

///
let package = Package(
    name: "swift-collections-extensions",
    products: [
        .library(
            name: "swift-collections-extensions",
            targets: ["swift-collections-extensions"]
        ),
    ],
    dependencies: [
        
        ///
        .package(
            url: "https://github.com/jeremyabannister/CollectionConcurrencyKit",
            "0.2.3" ..< "0.3.0"
        ),
        
        ///
        .package(
            url: "https://github.com/apple/swift-collections",
            "1.1.0" ..< "2.0.0"
        ),
    ],
    targets: [
        .target(
            name: "swift-collections-extensions",
            dependencies: [
                
                ///
                "CollectionConcurrencyKit",
                
                ///
                .product(
                    name: "OrderedCollections",
                    package: "swift-collections"
                ),
            ]
        ),
        .testTarget(
            name: "swift-collections-extensions-tests",
            dependencies: ["swift-collections-extensions"]
        ),
    ]
)
