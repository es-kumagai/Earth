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

public protocol RawRepresentingProtocol : MemberMacro, ExtensionMacro {
    
    static var attributeIdentifer: IdentifierTypeSyntax { get }
    static var rawValueModifier: ExprSyntax { get }
    static var constantsEnumName: String { get }
}

public extension RawRepresentingProtocol {
    
    static var constantsEnumName: String {
        "RawRepresentingConstants"
    }
    
    static func expansion(of node: AttributeSyntax, attachedTo declaration: some DeclGroupSyntax, providingExtensionsOf type: some TypeSyntaxProtocol, conformingTo protocols: [TypeSyntax], in context: some MacroExpansionContext) throws -> [ExtensionDeclSyntax] {
        
        guard
            declaration.is(either: StructDeclSyntax.self, ClassDeclSyntax.self) else {
            
            throw RawRepresentingError.unsupported("This macro can be applied to a `struct` or a `class`.")
        }
        
        guard let constantsEnum = declaration.memberBlock.enumerations.first(withTypeName: constantsEnumName) else {
            return []
        }

        let rawType = try rawType(of: declaration)
        let modifiers = declaration.modifiers.accessControls
        let constantsDefinitions = try makeConstants(for: constantsEnum, rawType: rawType)
        
        let `extension` = ExtensionDeclSyntax(modifiers: modifiers, extendedType: type) {
            
            for definition in constantsDefinitions {
                definition
            }
        }
        
        return [`extension`]
    }
    
    static func expansion(of node: AttributeSyntax, providingMembersOf declaration: some DeclGroupSyntax, in context: some MacroExpansionContext) throws -> [DeclSyntax] {
        
        guard
            declaration.is(either: StructDeclSyntax.self, ClassDeclSyntax.self) else {
            
            throw RawRepresentingError.unsupported("This macro can be applied to a `struct` or a `class`.")
        }
        
        let specifyingModifier = switch declaration.modifiers.primaryAccessControl?.name.text {
            
        case nil:
            ""
            
        case "open":
            "public "
            
        case let modifier?:
            "\(modifier) "
        }
        
        let rawType = try rawType(of: declaration)
        
        let expression: ExprSyntax = """
        \(raw: specifyingModifier)\(rawValueModifier) rawValue: \(rawType)
        
        \(raw: specifyingModifier)init(rawValue: \(rawType)) {
            self.rawValue = rawValue
        }
        """
        
        return [
            "\(expression.formatted())"
        ]
    }
}

private extension RawRepresentingProtocol {

    static func makeConstants(for enumeration: EnumDeclSyntax, rawType: GenericArgumentSyntax) throws -> [VariableDeclSyntax] {
        
        var prefix: String?
        
        return try enumeration.flatElements.map { element in
            
            let baseName = element.name
            
            return switch (element.rawValue, prefix) {
                
            case (let rawValue?, _):
                try makeVariableDefinition(for: baseName, with: rawValue, currentPrefix: &prefix, rawType: rawType)
                
            case (nil, let prefix?):
                try makeVariableDefinition(for: baseName, withCurrentPrefix: prefix, rawType: rawType)
                
            case (nil, nil):
                throw RawRepresentingError.unexpectedSyntax("Raw value must be specified at least on the first enumeration case.")
            }
        }
    }
    
    static func rawType(of declaration: some DeclGroupSyntax) throws -> GenericArgumentSyntax {
        
        guard let attribute = declaration.attributes.first(having: attributeIdentifer) else {
            
            throw RawRepresentingError.unexpectedSyntax("The attribute itself cannot be detected.")
        }
        
        guard let rawValue = attribute.attributeIdentifier?.genericArguments?.casted.first else {
            
            throw RawRepresentingError.unexpectedSyntax("No `RawValue` type specified by the 1st generic parameter.")
        }
        
        return rawValue
    }
    
    static func makeVariableDefinition(for baseName: TokenSyntax, with newRawValue: InitializerClauseSyntax, currentPrefix: inout String!, rawType: GenericArgumentSyntax) throws -> VariableDeclSyntax {
        
        if let newRawValue = newRawValue.value.as(StringLiteralExprSyntax.self) {
            
            currentPrefix = newRawValue.text
            
            return try makeVariableDefinition(for: baseName, withCurrentPrefix: currentPrefix, rawType: rawType)
        }
        
        if let newRawValue = newRawValue.as(IntegerLiteralExprSyntax.self) {
            
            return try makeVariableDefinition(for: baseName, rawType: rawType, initialValue: "\(newRawValue.literal)")
        }
        
        if let newRawValue = newRawValue.as(FloatLiteralExprSyntax.self) {
            
            return try makeVariableDefinition(for: baseName, rawType: rawType, initialValue: "\(newRawValue.literal)")
        }
        
        throw RawRepresentingError.unexpectedSyntax("The raw value is type of either a string literal or a number (integer/float) literal.")
    }
    
    static func makeVariableDefinition(for variableName: TokenSyntax, rawType: GenericArgumentSyntax, initialValue: ExprSyntax) throws -> VariableDeclSyntax {
        
        let variableName = IdentifierPatternSyntax(identifier: variableName)
        let rawType = TypeSyntax("\(rawType)")
        let typeAnnotation = TypeAnnotationSyntax(type: rawType)
        let initialValue = InitializerClauseSyntax(value: initialValue)
        
        let modifiers = DeclModifierListSyntax("static")
        let bindings = PatternBindingListSyntax {
            PatternBindingSyntax(pattern: variableName, typeAnnotation: typeAnnotation, initializer: initialValue)
        }
        
        return VariableDeclSyntax(modifiers: modifiers, bindingSpecifier: "let", bindings: bindings)
    }

    static func makeVariableDefinition(for variableName: TokenSyntax, withCurrentPrefix prefix: String, rawType: GenericArgumentSyntax) throws -> VariableDeclSyntax {
        
        let constantName = variableName.prefixed(with: prefix, uppercasedFirstLetter: true)
        let initialValue = ExprSyntax("\(constantName)")
        
        return try makeVariableDefinition(for: variableName, rawType: rawType, initialValue: initialValue)
    }
}
