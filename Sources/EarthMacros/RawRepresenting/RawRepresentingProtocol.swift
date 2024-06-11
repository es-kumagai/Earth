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
    static var constantsPrefixParameterName: String { get }
}

public extension RawRepresentingProtocol {
    
    static var constantsEnumName: String {
        "RawRepresentingConstants"
    }
    
    static var constantsPrefixParameterName: String {
        "constantPrefix"
    }
    
    static func expansion(of node: AttributeSyntax, attachedTo declaration: some DeclGroupSyntax, providingExtensionsOf type: some TypeSyntaxProtocol, conformingTo protocols: [TypeSyntax], in context: some MacroExpansionContext) throws -> [ExtensionDeclSyntax] {
        
        guard
            declaration.is(either: StructDeclSyntax.self, ClassDeclSyntax.self) else {
            
            throw RawRepresentingError.unsupported("This macro can be applied to a `struct` or a `class`.")
        }
        
        guard let constantsEnum = declaration.memberBlock.enumerations.first(withTypeName: constantsEnumName) else {
            return []
        }

        guard let attribute = declaration.attributes.first(having: attributeIdentifer) else {
            
            throw RawRepresentingError.unexpectedSyntax("The attribute itself cannot be detected.")
        }
        
        let prefix = try constantPrefix(of: attribute)
        let rawType = try rawType(of: attribute)
        let modifiers = declaration.modifiers.accessControls
        let constantsDefinitions = try makeConstants(for: constantsEnum, valueType: type, rawType: rawType, prefix: prefix)
        
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
        
        let attribute = try attribute(of: declaration)
        let rawType = try rawType(of: attribute)
        
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

    static func makeConstants(for enumeration: EnumDeclSyntax, valueType: some TypeSyntaxProtocol, rawType: GenericArgumentSyntax, prefix: String) throws -> [VariableDeclSyntax] {
        
        return try enumeration.flatElements.map { element in
            
            let baseName = element.name
            
            return switch element.rawValue {
                
            case let rawValue?:
                try makeVariableDefinition(for: baseName, with: rawValue, valueType: valueType, rawType: rawType)
                
            case nil:
                try makeVariableDefinition(for: baseName, valueType: valueType, rawType: rawType, initialValue: "\(raw: prefix)\(baseName.uppercasedFirstLetter)")
            }
        }
    }
    
    static func attribute(of declaration: some DeclGroupSyntax) throws -> AttributeSyntax {
        
        guard let attribute = declaration.attributes.first(having: attributeIdentifer) else {
            
            throw RawRepresentingError.unexpectedSyntax("The attribute itself cannot be detected.")
        }
        
        return attribute
    }

    static func constantPrefix(of attribute: AttributeSyntax) throws -> String {
        
        guard let parameter = attribute.parameters?.first(havingName: constantsPrefixParameterName) else {
            return ""
        }

        return parameter.expression.as(StringLiteralExprSyntax.self)!.text
    }
    
    static func rawType(of attribute: AttributeSyntax) throws -> GenericArgumentSyntax {
        
        guard let rawValue = attribute.attributeIdentifier?.genericArguments?.casted.first else {
            
            throw RawRepresentingError.unexpectedSyntax("No `RawValue` type specified by the 1st generic parameter.")
        }
        
        return rawValue
    }
    
    static func makeVariableDefinition(for baseName: TokenSyntax, with newRawValue: InitializerClauseSyntax, valueType: some TypeSyntaxProtocol, rawType: GenericArgumentSyntax) throws -> VariableDeclSyntax {
        
        if let newRawValue = newRawValue.value.as(StringLiteralExprSyntax.self) {
            
            return try makeVariableDefinition(for: baseName, valueType: valueType, rawType: rawType, initialValue: "\(raw: newRawValue.text)")
        }
        
        if let newRawValue = newRawValue.as(IntegerLiteralExprSyntax.self) {
            
            return try makeVariableDefinition(for: baseName, valueType: valueType, rawType: rawType, initialValue: "\(newRawValue.literal)")
        }
        
        if let newRawValue = newRawValue.as(FloatLiteralExprSyntax.self) {
            
            return try makeVariableDefinition(for: baseName, valueType: valueType, rawType: rawType, initialValue: "\(newRawValue.literal)")
        }
        
        throw RawRepresentingError.unexpectedSyntax("The raw value is type of either a string literal or a number (integer/float) literal.")
    }
    
    static func makeVariableDefinition(for variableName: TokenSyntax, valueType: some TypeSyntaxProtocol, rawType: GenericArgumentSyntax, initialValue: ExprSyntax) throws -> VariableDeclSyntax {
        
        let variableName = IdentifierPatternSyntax(identifier: variableName)
        let initialValue = InitializerClauseSyntax(value: ExprSyntax("\(valueType)(rawValue: \(initialValue))"))
        
        let modifiers = DeclModifierListSyntax("static")
        let bindings = PatternBindingListSyntax {
            PatternBindingSyntax(pattern: variableName, initializer: initialValue)
        }
        
        return VariableDeclSyntax(modifiers: modifiers, bindingSpecifier: "let", bindings: bindings)
    }
}
