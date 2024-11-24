//
//  RawRepresentingProtocol.swift
//
//  
//  Created by Tomohiro Kumagai on 2024/06/10
//  
//

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import EarthMacroCrust

public protocol RawRepresentingProtocol : MemberMacro {
    
    static var attributeIdentifer: IdentifierTypeSyntax { get }
    static var rawValueModifier: ExprSyntax { get }
    static var constantsEnumName: String { get }
    static var constantsPrefixParameterName: String { get }
}

public extension RawRepresentingProtocol {
    
    static var renamedEnumerationNames: [String: String] {
        [
            "RawRepresentingConstants": "RawRepresentingByConstants",
            "RawRepresentingLiterals": "RawRepresentingByLiterals"
        ]
    }
    static var constantsEnumName: String {
        "RawRepresentingByConstants"
    }
    
    static var literalsEnumName: String {
        "RawRepresentingByLiterals"
    }

    static var constantsPrefixParameterName: String {
        "constantPrefix"
    }
    
    static func expansion(of node: AttributeSyntax, providingMembersOf declaration: some DeclGroupSyntax, in context: some MacroExpansionContext) throws -> [DeclSyntax] {
        
        let accessControl = specifyingAccessControlModifier(of: declaration)
        let attribute = try attribute(of: declaration)
        let rawType = try rawType(of: attribute)
        
        checkWhetherUsingDeprecatedNames(in: declaration, context: context)
        
        let rawValueDefinition = makeRawValueImplementation(of: declaration, accessControl: accessControl, rawType: rawType)
        let constantDefinitions = try makeConstantsImplementation(of: declaration, attribute: attribute, accessControl: accessControl)
        let literalDefinitions = try makeLiteralsImplementation(of: declaration, attribute: attribute, accessControl: accessControl)

        return CollectionOfOne("\(rawValueDefinition.formatted())") + constantDefinitions.map(DeclSyntax.init) + literalDefinitions.map(DeclSyntax.init)
    }
}

private extension RawRepresentingProtocol {

    static func checkWhetherUsingDeprecatedNames(in declaration: DeclGroupSyntax, context: some MacroExpansionContext) {
        
        for enumeration in declaration.memberBlock.enumerations {
            
            let currentName = enumeration.name.text
            
            if let renamedName = renamedEnumerationNames[currentName] {
                
                context.addDiagnostics(from: RawRepresentingError.deprecatedEnumerationName("'\(currentName)' is renamed by '\(renamedName)'."), node: enumeration)
            }
        }
    }

    static func specifyingAccessControlModifier(of declaration: DeclGroupSyntax) -> String? {
        
        switch declaration.modifiers.primaryAccessControl?.name.text {
            
        case nil:
            nil
            
        case "open":
            "public"
            
        case let modifier?:
            "\(modifier)"
        }
    }
    
    static func makeRawValueImplementation(of declaration: some DeclGroupSyntax, accessControl: String?, rawType: some SyntaxProtocol) -> ExprSyntax {
        
        let accessControl = if let accessControl {
            "\(accessControl) "
        } else {
            ""
        }
        
        return """
        \(raw: accessControl)\(rawValueModifier) rawValue: \(rawType)
        
        \(raw: accessControl)init(rawValue: \(rawType)) {
            self.rawValue = rawValue
        }
        """
    }
    
    static func makeConstantsImplementation(of declaration: some DeclGroupSyntax, attribute: AttributeSyntax, accessControl: String?) throws -> [VariableDeclSyntax] {

        guard let constantsEnum = declaration.memberBlock.enumerations.first(withTypeName: constantsEnumName) else {
            return []
        }

        let type = try targetType(of: declaration)
        let prefix = try constantPrefix(of: attribute)
        let rawType = try rawType(of: attribute)
        let constantsDefinitions = try makeConstants(for: constantsEnum, valueType: type, rawType: rawType, accessControl: accessControl, constantPrefix: prefix)

        return constantsDefinitions
    }

    static func makeLiteralsImplementation(of declaration: some DeclGroupSyntax, attribute: AttributeSyntax, accessControl: String?) throws -> [VariableDeclSyntax] {

        guard let literalsEnum = declaration.memberBlock.enumerations.first(withTypeName: literalsEnumName) else {
            return []
        }

        let type = try targetType(of: declaration)
        let rawType = try rawType(of: attribute)
        let literalsDefinitions = try makeLiterals(for: literalsEnum, valueType: type, rawType: rawType, accessControl: accessControl)

        return literalsDefinitions
    }
    
    static func makeConstants(for enumeration: EnumDeclSyntax, valueType: some TypeSyntaxProtocol, rawType: GenericArgumentSyntax, accessControl: String?, constantPrefix: String?) throws -> [VariableDeclSyntax] {
        
        return try enumeration.allCaseElements.map { element in
            
            let baseName = element.name.unbackticked
            
            return switch element.rawValue {
                
            case let rawValue?:
                try makeConstantDefinition(for: baseName, with: rawValue, valueType: valueType, rawType: rawType, accessControl: accessControl)
                
            case nil:
                if let constantPrefix {
                    try makePropertyDefinition(for: baseName, valueType: valueType, rawType: rawType, accessControl: accessControl, initialValue: "\(raw: constantPrefix)\(baseName.uppercasedFirstLetter)")
                } else {
                    try makePropertyDefinition(for: baseName, valueType: valueType, rawType: rawType, accessControl: accessControl, initialValue: "\(baseName)")
                }
            }
        }
    }
    
    static func makeLiterals(for enumeration: EnumDeclSyntax, valueType: some TypeSyntaxProtocol, rawType: GenericArgumentSyntax, accessControl: String?) throws -> [VariableDeclSyntax] {
        
        return try enumeration.allCaseElements.map { element in
            
            let baseName = element.name
            
            return switch element.rawValue {
                
            case let rawValue?:
                try makeLiteralDefinition(for: baseName, with: rawValue, valueType: valueType, rawType: rawType, accessControl: accessControl)
                
            case nil:
                try makePropertyDefinition(for: baseName, valueType: valueType, rawType: rawType, accessControl: accessControl, initialValue: #""\#(baseName)""#)
            }
        }
    }

    static func attribute(of declaration: some DeclGroupSyntax) throws -> AttributeSyntax {
        
        guard let attribute = declaration.attributes.first(having: attributeIdentifer) else {
            
            throw RawRepresentingError.unexpectedSyntax("The attribute itself cannot be detected.")
        }
        
        return attribute
    }

    static func constantPrefix(of attribute: AttributeSyntax) throws -> String? {
        
        guard let parameter = attribute.parameters?.first(havingName: constantsPrefixParameterName) else {
            return nil
        }

        return parameter.expression.as(StringLiteralExprSyntax.self)!.text
    }
    
    static func rawType(of attribute: AttributeSyntax) throws -> GenericArgumentSyntax {
        
        guard let rawValue = attribute.attributeIdentifier?.genericArguments?.casted.first else {
            
            throw RawRepresentingError.unexpectedSyntax("No `RawValue` type specified by the 1st generic parameter.")
        }
        
        return rawValue
    }
    
    static func makePropertyDefinition(for variableName: TokenSyntax, valueType: some TypeSyntaxProtocol, rawType: GenericArgumentSyntax, accessControl: String?, initialValue: ExprSyntax) throws -> VariableDeclSyntax {
        
        let variableName = IdentifierPatternSyntax(identifier: "\(raw: variableName.text)")
        let initialValue = InitializerClauseSyntax(value: ExprSyntax("\(valueType)(rawValue: \(initialValue))"))
        
        let modifiers = if let accessControl { DeclModifierListSyntax(accessControl, "static")
        } else {
            DeclModifierListSyntax("static")
        }
        let bindings = PatternBindingListSyntax {
            PatternBindingSyntax(pattern: variableName, initializer: initialValue)
        }
        
        return VariableDeclSyntax(modifiers: modifiers, bindingSpecifier: "let", bindings: bindings)
    }

    static func makeConstantDefinition(for baseName: TokenSyntax, with newRawValue: InitializerClauseSyntax, valueType: some TypeSyntaxProtocol, rawType: GenericArgumentSyntax, accessControl: String?) throws -> VariableDeclSyntax {
        
        if let newRawValue = newRawValue.value.as(StringLiteralExprSyntax.self) {
            
            return try makePropertyDefinition(for: baseName, valueType: valueType, rawType: rawType, accessControl: accessControl, initialValue: "\(raw: newRawValue.text)")
        }
        
        if let newRawValue = newRawValue.value.as(IntegerLiteralExprSyntax.self) {
            
            return try makePropertyDefinition(for: baseName, valueType: valueType, rawType: rawType, accessControl: accessControl, initialValue: "\(newRawValue.literal)")
        }
        
        if let newRawValue = newRawValue.value.as(FloatLiteralExprSyntax.self) {
            
            return try makePropertyDefinition(for: baseName, valueType: valueType, rawType: rawType, accessControl: accessControl, initialValue: "\(newRawValue.literal)")
        }
        
        throw RawRepresentingError.unexpectedSyntax("The raw value is type of either a string literal or a number (integer/float) literal.")
    }
    
    static func makeLiteralDefinition(for baseName: TokenSyntax, with newRawValue: InitializerClauseSyntax, valueType: some TypeSyntaxProtocol, rawType: GenericArgumentSyntax, accessControl: String?) throws -> VariableDeclSyntax {
        
        if let newRawValue = newRawValue.value.as(StringLiteralExprSyntax.self) {
            
            return try makePropertyDefinition(for: baseName, valueType: valueType, rawType: rawType, accessControl: accessControl, initialValue: "\(newRawValue)")
        }
        
        if let newRawValue = newRawValue.value.as(IntegerLiteralExprSyntax.self) {
            
            return try makePropertyDefinition(for: baseName, valueType: valueType, rawType: rawType, accessControl: accessControl, initialValue: "\(newRawValue.literal)")
        }
        
        if let newRawValue = newRawValue.value.as(FloatLiteralExprSyntax.self) {
            
            return try makePropertyDefinition(for: baseName, valueType: valueType, rawType: rawType, accessControl: accessControl, initialValue: "\(newRawValue.literal)")
        }
        
        throw RawRepresentingError.unexpectedSyntax("The raw value is type of either a string literal or a number (integer/float) literal.")
    }

    static func targetType(of declaration: some DeclGroupSyntax) throws -> TypeSyntaxProtocol {
                
        if
            let decl = declaration.as(StructDeclSyntax.self) {
            TypeSyntax("\(raw: decl.name.text)")
        } else if let decl = declaration.as(ClassDeclSyntax.self) {
            TypeSyntax("\(raw: decl.name.text)")
        } else {
            throw RawRepresentingError.unsupported("This macro can be applied to a `struct` or a `class`.")
        }
    }
}
