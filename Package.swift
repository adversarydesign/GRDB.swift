// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import Foundation
import PackageDescription

var swiftSettings: [SwiftSetting] = [
    .define("SQLITE_ENABLE_FTS5"),
]
var cSettings: [CSetting] = []
var dependencies: [PackageDescription.Package.Dependency] = []

// For Swift 5.8+
//swiftSettings.append(.enableUpcomingFeature("ExistentialAny"))

// Don't rely on those environment variables. They are ONLY testing conveniences:
// $ SQLITE_ENABLE_PREUPDATE_HOOK=1 make test_SPM
if ProcessInfo.processInfo.environment["SQLITE_ENABLE_PREUPDATE_HOOK"] == "1" {
    swiftSettings.append(.define("SQLITE_ENABLE_PREUPDATE_HOOK"))
    cSettings.append(.define("GRDB_SQLITE_ENABLE_PREUPDATE_HOOK"))
}

// The SPI_BUILDER environment variable enables documentation building
// on <https://swiftpackageindex.com/groue/GRDB.swift>. See
// <https://github.com/SwiftPackageIndex/SwiftPackageIndex-Server/issues/2122>
// for more information.
//
// SPI_BUILDER also enables the `make docs-localhost` command.
if ProcessInfo.processInfo.environment["SPI_BUILDER"] == "1" {
    dependencies.append(.package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"))
}

let package = Package(
    name: "GRDB",
    defaultLocalization: "en", // for tests
    platforms: [
        .iOS(.v11),
        .macOS(.v10_13),
        .tvOS(.v11),
        .watchOS(.v4),
    ],
    products: [
        .library(name: "CSQLite", targets: ["CSQLite"]),
        .library(name: "GRDB", targets: ["GRDB"]),
        .library(name: "GRDB-dynamic", type: .dynamic, targets: ["GRDB"]),
    ],
    dependencies: dependencies,
    targets: [
        // waxjaw: bundled SQLite amalgamation (public domain) instead of the
        // system library. Flags mirror Apple's build where waxjaw depends on them.
        .target(
            name: "CSQLite",
            path: "Sources/CSQLite",
            exclude: ["sqlite3-amalgamation.c"],
            cSettings: [
                .define("SQLITE_ENABLE_FTS5"),
                .define("SQLITE_ENABLE_FTS3"),
                .define("SQLITE_ENABLE_FTS3_PARENTHESIS"),
                .define("SQLITE_ENABLE_FTS4"),
                .define("SQLITE_ENABLE_RTREE"),
                .define("SQLITE_ENABLE_SNAPSHOT"),
                .define("SQLITE_ENABLE_DBSTAT_VTAB"),
                .define("SQLITE_ENABLE_COLUMN_METADATA"),
                .define("SQLITE_ENABLE_MATH_FUNCTIONS"),
                .define("SQLITE_ENABLE_API_ARMOR"),
                .define("SQLITE_USE_URI", to: "1"),
                .define("SQLITE_THREADSAFE", to: "2"),
                .define("SQLITE_DQS", to: "0"),
                .define("SQLITE_DEFAULT_WAL_SYNCHRONOUS", to: "1"),
                .define("SQLITE_DEFAULT_MEMSTATUS", to: "0"),
                .define("SQLITE_MAX_VARIABLE_NUMBER", to: "500000"),
                .define("SQLITE_LIKE_DOESNT_MATCH_BLOBS"),
                .define("SQLITE_OMIT_LOAD_EXTENSION"),
                .define("SQLITE_OMIT_DEPRECATED"),
                // SQLite 3.54 refuses a statement that references a CTE after it has
                // allocated SQLITE_MAX_EXPR_DEPTH cursors (select.c, 2026-10-04 fix).
                // waxjaw browse statements inline the hidden-file predicate many
                // times; the largest measured one needs 5,814 cursors (2026-10-23).
                // 16,000 restores the pre-3.54 behavior with headroom. Generated SQL
                // never nests expressions near this depth.
                .define("SQLITE_MAX_EXPR_DEPTH", to: "16000"),
                .define("HAVE_USLEEP", to: "1"),
                .define("HAVE_ISNAN", to: "1"),
            ]),
        .target(
            name: "GRDB",
            dependencies: ["CSQLite"],
            path: "GRDB",
            resources: [.copy("PrivacyInfo.xcprivacy")],
            cSettings: cSettings,
            swiftSettings: swiftSettings),
        .testTarget(
            name: "GRDBTests",
            dependencies: ["GRDB"],
            path: "Tests",
            exclude: [
                "CocoaPods",
                "Crash",
                "CustomSQLite",
                "GRDBTests/getThreadsCount.c",
                "Info.plist",
                "Performance",
                "SPM",
                "generatePerformanceReport.rb",
                "parsePerformanceTests.rb",
            ],
            resources: [
                .copy("GRDBTests/Betty.jpeg"),
                .copy("GRDBTests/InflectionsTests.json"),
                .copy("GRDBTests/Issue1383.sqlite"),
            ],
            cSettings: cSettings,
            swiftSettings: swiftSettings)
    ],
    swiftLanguageVersions: [.v5]
)
