// The Swift Programming Language
// https://docs.swift.org/swift-book

@attached(member, names: named(init(rawValue:)), named(rawValue))
public macro RawRepresenting<RawType>() = #externalMacro(module: "EarthMacros", type: "RawRepresenting")

@attached(member, names: named(init(rawValue:)), named(rawValue))
public macro RewritableRawRepresenting<RawType>() = #externalMacro(module: "EarthMacros", type: "RewritableRawRepresenting")
