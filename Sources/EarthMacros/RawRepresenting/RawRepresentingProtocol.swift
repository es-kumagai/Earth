//
//  RawRepresentingProtocol.swift
//
//  
//  Created by Tomohiro Kumagai on 2024/06/10
//  
//

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public protocol RawRepresentingProtocol : MemberMacro {
    
    static var attributeIdentifer: IdentifierTypeSyntax { get }
    static var rawValueModifier: ExprSyntax { get }
}

public extension RawRepresentingProtocol {
    
    static func expansion(of node: AttributeSyntax, providingMembersOf declaration: some DeclGroupSyntax, in context: some MacroExpansionContext) throws -> [DeclSyntax] {
        
        guard
            declaration.is(StructDeclSyntax.self) || declaration.is(ClassDeclSyntax.self) else {
            
            throw RawRepresentingError.unsupported("This macro can be applied to a `struct` or a `class`.")
        }
        
        let targetModifiers: Set = [
            "public", "internal", "fileprivate", "private", "module"
        ]
        
        let existingModifiers = declaration.modifiers.map(\.name.text)
        
        let specifyingModifier: String = {
            
            guard let modifier = targetModifiers.intersection(existingModifiers).first else {
                
                return ""
            }
            
            return if modifier == "open" {
                "public "
            } else {
                "\(modifier) "
            }
        }()
                
        guard let attribute = declaration.attributes.first(having: attributeIdentifer) else {
            
            throw RawRepresentingError.unexpectedSyntax("The attribute itself cannot be detected.")
        }
        
        guard let rawValue = attribute.attributeIdentifier?.genericArguments?.casted.first else {
            
            throw RawRepresentingError.unexpectedSyntax("No `RawValue` type specified by the 1st generic parameter.")
        }

        let expression: ExprSyntax = """
        \(raw: specifyingModifier)\(rawValueModifier) rawValue: \(rawValue)
        
        \(raw: specifyingModifier)init(rawValue: \(rawValue)) {
            self.rawValue = rawValue
        }
        """
    
        return [
            "\(expression.formatted())"
        ]
    }}
