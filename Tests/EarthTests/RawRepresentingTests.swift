import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

// Macro implementations build for the host, so the corresponding module is not available when cross-compiling. Cross-compiled tests may still make use of the macro itself in end-to-end tests.
#if canImport(EarthMacros)
import EarthMacros

let testMacros: [String: Macro.Type] = [
    "RawRepresenting": RawRepresenting.self,
    "MutableRawRepresenting": MutableRawRepresenting.self,
]
#endif

final class RawRepresentingTests: XCTestCase {
    func testImmutable() throws {
#if canImport(EarthMacros)
        assertMacroExpansion(
            """
            @RawRepresenting<Int>
            struct Value : RawValue {
            }
            """,
            expandedSource: """
            
            struct Value : RawValue {
            
                let rawValue: Int
            
                init(rawValue: Int) {
                    self.rawValue = rawValue
                }
            }
            """,
            macros: testMacros
        )
#else
        throw XCTSkip("macros are only supported when running tests for the host platform")
#endif
    }
    
    func testMutable() throws {
#if canImport(EarthMacros)
        assertMacroExpansion(
                """
                @MutableRawRepresenting<Int>
                struct Value : RawValue {
                }
                """,
                expandedSource: """
                
                struct Value : RawValue {
                
                    var rawValue: Int
                
                    init(rawValue: Int) {
                        self.rawValue = rawValue
                    }
                }
                """,
                macros: testMacros
        )
#else
        throw XCTSkip("macros are only supported when running tests for the host platform")
#endif
    }
    
    func testAccessControl() throws {
#if canImport(EarthMacros)
        assertMacroExpansion(
            """
            @RawRepresenting<Int>
            public struct Value : RawValue {
            }
            """,
            expandedSource: """
            
            public struct Value : RawValue {
            
                public let rawValue: Int
            
                public init(rawValue: Int) {
                    self.rawValue = rawValue
                }
            }
            """,
            macros: testMacros
        )
        
        assertMacroExpansion(
            """
            @RawRepresenting<Int>
            open struct Value : RawValue {
            }
            """,
            expandedSource: """
            
            open struct Value : RawValue {
            
                public let rawValue: Int
            
                public init(rawValue: Int) {
                    self.rawValue = rawValue
                }
            }
            """,
            macros: testMacros
        )
        
        assertMacroExpansion(
            """
            @RawRepresenting<Int>
            fileprivate struct Value : RawValue {
            }
            """,
            expandedSource: """
            
            fileprivate struct Value : RawValue {
            
                fileprivate let rawValue: Int
            
                fileprivate init(rawValue: Int) {
                    self.rawValue = rawValue
                }
            }
            """,
            macros: testMacros
        )
#else
        throw XCTSkip("macros are only supported when running tests for the host platform")
#endif
    }
    
    func testConstants() throws {
#if canImport(EarthMacros)
        assertMacroExpansion(
            """
            @RawRepresenting<Int>(constantPrefix: "kParameter")
            public struct Test {

                private enum RawRepresentingConstants {
                    case scope
                    case element
                }
            }
            """,
            expandedSource: """
            
            public struct Test {

                private enum RawRepresentingConstants {
                    case scope
                    case element
                }
            
                public let rawValue: Int
            
                public init(rawValue: Int) {
                    self.rawValue = rawValue
                }

                public static let scope = Test(rawValue: kParameterScope)
            
                public static let element = Test(rawValue: kParameterElement)
            }
            """,
            macros: testMacros
        )
#else
        throw XCTSkip("macros are only supported when running tests for the host platform")
#endif
    }}
