// The Swift Programming Language
// https://docs.swift.org/swift-book

@attached(member, names: named(init(rawValue:)), named(rawValue), arbitrary)
public macro RawRepresenting<RawType>(constantPrefix: String = "") = #externalMacro(module: "EarthMacros", type: "RawRepresenting")

@attached(member, names: named(init(rawValue:)), named(rawValue), arbitrary)
public macro MutableRawRepresenting<RawType>(constantPrefix: String = "") = #externalMacro(module: "EarthMacros", type: "MutableRawRepresenting")
