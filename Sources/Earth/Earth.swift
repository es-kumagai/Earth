// The Swift Programming Language
// https://docs.swift.org/swift-book

@attached(member, names: named(init(rawValue:)), named(rawValue))
public macro RawRepresenting<RawType>(x: Int = 0) = #externalMacro(module: "EarthMacros", type: "RawRepresenting")

@attached(member, names: named(init(rawValue:)), named(rawValue))
public macro RewritableRawRepresenting<RawType>(x: Int = 0) = #externalMacro(module: "EarthMacros", type: "RewritableRawRepresenting")
