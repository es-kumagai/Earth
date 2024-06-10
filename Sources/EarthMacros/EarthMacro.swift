import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

@main
struct EarthPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        RawRepresenting.self,
        MutableRawRepresenting.self,
    ]
}
