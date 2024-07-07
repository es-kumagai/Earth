//
//  SwiftSyntaxMake.swift
//
//  
//  Created by Tomohiro Kumagai on 2024/06/08
//  
//

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftUI
import SwiftSyntaxMacros

public enum SwiftSyntaxMake {
    
}

public extension SwiftSyntaxMake {
    
    struct FunctionEffectSet : OptionSet {
        
        public let rawValue: UInt
        
        public init(rawValue: UInt) {
            self.rawValue = rawValue
        }
    }
}

public extension SwiftSyntaxMake.FunctionEffectSet {
    
    static let throwing = Self(rawValue: 1 << 1)
    static let asynchronous = Self(rawValue: 1 << 2)
    
    var token: TokenSyntax? {
        
        switch self {
            
        case .throwing:
            return SwiftSyntaxMake.token("throws")
            
        case .asynchronous:
            return SwiftSyntaxMake.token("async")
            
        default:
            return nil
        }
    }
    
    func makeEffectSpecifiers() -> FunctionEffectSpecifiersSyntax? {
        
        guard !self.isEmpty else {
            return nil
        }
        
        func tokenIfContained(_ effect: Self) -> TokenSyntax? {
            
            self.contains(effect) ? effect.token : nil
        }
        
        let throwing = tokenIfContained(.throwing)
        let asynchronous = tokenIfContained(.asynchronous)
        
        return FunctionEffectSpecifiersSyntax(asyncSpecifier: asynchronous, throwsSpecifier: throwing)
    }
}

public extension SwiftSyntaxMake {
    
    typealias LabeledValue = (label: String?, value: String)
    typealias LabeledValues = [LabeledValue]
    
    typealias ParameterItem = (firstName: String, secondName: String?, typeName: String)
    typealias ParameterItems = [ParameterItem]
    
    static func token(_ name: some StringProtocol) -> TokenSyntax {
        TokenSyntax("\(raw: name)")
    }

    static func typeAnnotation(_ typeName: some StringProtocol) throws -> TypeAnnotationSyntax {
        
        let type = try type(typeName)
        return TypeAnnotationSyntax(type: type)
    }

    static func typeAnnotation(_ type: TypeSyntax) throws -> TypeAnnotationSyntax {
        TypeAnnotationSyntax(type: type)
    }

    static func typeAnnotation(_ typeName: some StringProtocol, genericArguments: (some Sequence<some StringProtocol>)?) throws -> TypeAnnotationSyntax {
        
        let type = try type(typeName, genericArguments: genericArguments)
        return TypeAnnotationSyntax(type: type)
    }
    
    static func identifierPattern(_ name: some StringProtocol) -> IdentifierPatternSyntax {
        
        IdentifierPatternSyntax(identifier: token(name))
    }

    static func typeAnnotation(_ typeName: some StringProtocol, genericArguments: [GenericArgumentSyntax]?) throws -> TypeAnnotationSyntax {
        
        let type = try type(typeName, genericArguments: genericArguments)
        return TypeAnnotationSyntax(type: type)
    }

    static func variable(_ name: some StringProtocol, type: some StringProtocol) throws -> VariableDeclSyntax {
        try variable(name, type: SwiftSyntaxMake.type(type))
    }
    
    static func variable(_ name: some StringProtocol, type: TypeSyntax) throws -> VariableDeclSyntax {

        let identifier = identifierPattern(name)
        let typeAnnotation = try typeAnnotation(type)
        
        let binding = PatternBindingListSyntax {

            PatternBindingSyntax(pattern: identifier, typeAnnotation: typeAnnotation)
        }
        
        return VariableDeclSyntax(bindingSpecifier: token("var"), bindings: binding)
    }
    
    static func constant(_ name: some StringProtocol, type: some StringProtocol) throws -> VariableDeclSyntax {

        let identifier = identifierPattern(name)
        let typeAnnotation = try typeAnnotation(type)
        
        let binding = PatternBindingListSyntax {

            PatternBindingSyntax(pattern: identifier, typeAnnotation: typeAnnotation)
        }
        
        return VariableDeclSyntax(bindingSpecifier: token("let"), bindings: binding)
    }

    static func modifier(_ name: some StringProtocol) -> DeclModifierSyntax {

        DeclModifierSyntax(name: token(name))
    }

    static func function(_ name: some StringProtocol, parameters: ParameterItems, effects: FunctionEffectSet? = nil, @CodeBlockItemListBuilder body: () throws -> CodeBlockItemListSyntax) throws -> FunctionDeclSyntax {

        let body = try CodeBlockSyntax(statements: body())
        return try function(name, parameters: parameters, effects: effects, body: body)
    }
    
    static func function(_ name: some StringProtocol, parameters: ParameterItems, returnType: TypeSyntax, effects: FunctionEffectSet? = nil, @CodeBlockItemListBuilder body: () throws -> CodeBlockItemListSyntax) throws -> FunctionDeclSyntax {
    
        let body = try CodeBlockSyntax(statements: body())
        return try function(name, parameters: parameters, returnType: returnType, effects: effects, body: body)
    }

    static func function(_ name: some StringProtocol, parameters: ParameterItems, effects: FunctionEffectSet? = nil, body: CodeBlockSyntax? = nil) throws -> FunctionDeclSyntax {
        
        let signature = try functionSignature(withParameters: parameters, effects: effects)
        
        return FunctionDeclSyntax(name: token(name), signature: signature, body: body)
    }
    
    static func function(_ name: some StringProtocol, parameters: ParameterItems, returnType: TypeSyntax, effects: FunctionEffectSet? = nil, body: CodeBlockSyntax? = nil) throws -> FunctionDeclSyntax {
        
        let signature = try functionSignature(withParameters: parameters, returnType: returnType, effects: effects)
        
        return FunctionDeclSyntax(name: token(name), signature: signature, body: body)
    }
    
    static func returnClause(typeName: some StringProtocol) throws -> ReturnClauseSyntax {
        
        let type = try type(typeName)
        return try returnClause(with: type)
    }
    
    static func returnClause(with type: TypeSyntax) throws -> ReturnClauseSyntax {
        
        ReturnClauseSyntax(type: type)
    }
    
    static func functionSignature(withParameters parameters: ParameterItems, effects: FunctionEffectSet? = nil) throws -> FunctionSignatureSyntax {
        
        let parameters = try functionParameters(parameters)
        return FunctionSignatureSyntax(parameterClause: parameters, effectSpecifiers: effects?.makeEffectSpecifiers())
    }
    
    static func functionSignature(withParameters parameters: ParameterItems, returnType: TypeSyntax, effects: FunctionEffectSet? = nil) throws -> FunctionSignatureSyntax {
        
        var signature = try functionSignature(withParameters: parameters, effects: effects)
        signature.returnClause = try returnClause(with: returnType)
        
        return signature
    }
    
    static func functionParameters(_ parameters: ParameterItems) throws -> FunctionParameterClauseSyntax {
        
        let parameters = try FunctionParameterListSyntax {
            
            for parameter in parameters {
                
                let firstName = token(parameter.firstName)
                let secondName = parameter.secondName.map(token(_:))
                let type = try type(parameter.typeName)
                
                FunctionParameterSyntax(firstName: firstName, secondName: secondName, type: type)
            }
        }
        
        return FunctionParameterClauseSyntax(parameters: parameters)
    }
    
    static func attributes(_ attributes: some Sequence<AttributeSyntax>) -> AttributeListSyntax {
        
        AttributeListSyntax {
            
            for attribute in attributes {
                attribute
            }
        }
    }
    
    static func attributes(@AttributeListBuilder _ predicate: () throws -> AttributeListSyntax) rethrows -> AttributeListSyntax {
        
        try predicate()
    }
    
    static func attribute(_ type: TypeSyntax, arguments: LabeledValues?) throws -> AttributeSyntax {
        
        let arguments = try arguments.map {
            try labeledExpressions($0)
        }
        
        return attribute(type, arguments: arguments)
    }
    
    static func attribute(_ type: TypeSyntax, arguments: LabeledExprListSyntax? = nil) -> AttributeSyntax {
        
        if let arguments {
            
            AttributeSyntax(attributeName: type, leftParen: token("("), arguments: .argumentList(arguments), rightParen: token(")"))
        } else {
            
            AttributeSyntax(attributeName: type)
        }
        
    }
    
    static func attribute(_ name: some StringProtocol, genericArguments: [GenericArgumentSyntax]? = nil, arguments: LabeledExprListSyntax? = nil) throws -> AttributeSyntax {
        
        let type = try type(name, genericArguments: genericArguments)

        return attribute(type, arguments: arguments)
    }

    static func attribute(_ name: some StringProtocol, genericArguments: [some StringProtocol]? = nil, arguments: LabeledValues?) throws -> AttributeSyntax {
        
        let type = try type(name, genericArguments: genericArguments)

        return try attribute(type, arguments: arguments)
    }

    static func attribute(_ name: some StringProtocol, genericArgument: GenericArgumentSyntax? = nil, arguments: LabeledExprListSyntax? = nil) throws -> AttributeSyntax {
        
        let type = try type(name, genericArgument: genericArgument)

        return attribute(type, arguments: arguments)
    }

    static func attribute(_ name: some StringProtocol, genericArgument: (some StringProtocol)? = nil, arguments: LabeledValues?) throws -> AttributeSyntax {
        
        let type = try type(name, genericArgument: genericArgument)
        let arguments = try arguments.map {
            try labeledExpressions($0)
        }
        
        return attribute(type, arguments: arguments)
    }

    static func attribute(_ name: some StringProtocol, genericArguments: (some Sequence<some StringProtocol>)? = nil) throws -> AttributeSyntax {
        
        let type = try type(name, genericArguments: genericArguments)

        return attribute(type)
    }

    static func identifierType(_ name: some StringProtocol) -> IdentifierTypeSyntax {
        
        IdentifierTypeSyntax(name: token(name))
    }
    
    static func memberType(_ name: some StringProtocol, member: TypeSyntax) -> MemberTypeSyntax {
        
        memberType(token(name), member: member)
    }
    
    static func memberType(_ name: TokenSyntax, member: TypeSyntax) -> MemberTypeSyntax {
        
        MemberTypeSyntax(baseType: member, name: name)
    }

    static func type(_ name: some StringProtocol, genericArgument: (some StringProtocol)?) throws -> TypeSyntax {
        
        let genericArguments = genericArgument.map { [$0] }
        
        return try type(name, genericArguments: genericArguments)
    }
    
    static func type(_ name: some StringProtocol, genericArgument: GenericArgumentSyntax?) throws -> TypeSyntax {
        
        let genericArguments = genericArgument.map { [$0] }
        
        return try type(name, genericArguments: genericArguments)
    }
    
    static func type(_ name: some StringProtocol, genericArguments: (some Sequence<some StringProtocol>)?) throws -> TypeSyntax {
        
        try type(names: name.split(separator: ".", omittingEmptySubsequences: false), genericArguments: genericArguments)
    }

    static func type(_ name: some StringProtocol) throws -> TypeSyntax {
        
        try type(names: name.split(separator: ".", omittingEmptySubsequences: false))
    }
    
    static func type(_ name: some StringProtocol, genericArguments: (some Sequence<GenericArgumentSyntax>)?) throws -> TypeSyntax {
        
        try type(names: name.split(separator: ".", omittingEmptySubsequences: false), genericArguments: genericArguments)
    }

    static func type(names: some Sequence<some StringProtocol>) throws -> TypeSyntax {
        
        let type = names.reduce(into: nil as TypeSyntax?) { type, name in
            
            switch type {
                
            case .none:
                type = TypeSyntax(identifierType(name))
                
            case .some(let member):
                type = TypeSyntax(memberType(name, member: member))
            }
        }
        
        guard let type else {
            throw MacroError.typeCannotBeGenerate("Cannot make type from '\(names.joined(separator: ".")).")
        }
        
        return type
    }

    static func type(names: some Sequence<some StringProtocol>, genericArguments: (some Sequence<some StringProtocol>)? = nil) throws -> TypeSyntax {
        
        let genericArguments = genericArguments.map {
            $0.map(genericArgument(_:))
        }

        return try type(names: names, genericArguments: genericArguments)
    }
    
    static func type(names: some Sequence<some StringProtocol>, genericArguments: (some Sequence<GenericArgumentSyntax>)? = nil) throws -> TypeSyntax {

        let type = try type(names: names)
        
        guard let genericArguments else {
            return type
        }
        
        let genericArgumentClause = genericArgumentClause(containing: genericArguments)
        
        if var type = type.as(IdentifierTypeSyntax.self) {
            
            type.genericArgumentClause = genericArgumentClause
            return TypeSyntax(type)
        }
        
        if var type = type.as(MemberTypeSyntax.self) {
            
            type.genericArgumentClause = genericArgumentClause
            return TypeSyntax(type)
        }
        
        throw MacroError.typeCannotBeGenerate("Unexpected type syntax '\(type)' is generated.")
    }
    
    static func genericArguments(containing arguments: some Sequence<GenericArgumentSyntax>) -> GenericArgumentListSyntax {
        
        GenericArgumentListSyntax {
            
            for argument in arguments {
                argument
            }
        }
    }
    
    static func genericArguments(containing arguments: some Sequence<some StringProtocol>) -> GenericArgumentListSyntax {
        
        let arguments = arguments.map {
            genericArgument($0)
        }
        
        return genericArguments(containing: arguments)
    }
    
    static func genericArgument(_ identifier: some StringProtocol) -> GenericArgumentSyntax {
        
        GenericArgumentSyntax(argument: identifierType(identifier))
    }
    
    static func genericArgumentClause(containing arguments: some Sequence<GenericArgumentSyntax>) -> GenericArgumentClauseSyntax {
        
        genericArgumentClause(with: genericArguments(containing: arguments))
    }
    
    static func genericArgumentClause(with arguments: GenericArgumentListSyntax) -> GenericArgumentClauseSyntax {
        
        GenericArgumentClauseSyntax(arguments: arguments)
    }
    
    static func referenceExpression(_ value: some StringProtocol) -> DeclReferenceExprSyntax {
        
        referenceExpression(token(value))
    }
    
    static func referenceExpression(_ value: TokenSyntax) -> DeclReferenceExprSyntax {
        
        DeclReferenceExprSyntax(baseName: value)
    }
    
    static func memberAccessExpression(_ components: some Sequence<some StringProtocol>) throws -> MemberAccessExprSyntax {
        
        var componentIterator = components.makeIterator()
        
        let first = componentIterator.next()
        let others = AnySequence({componentIterator}).map { component in
            referenceExpression(component)
        }
        
        guard let first, !others.isEmpty else {
            
            throw MacroError.invalidParameter("The components need to contain at least 2 elements.", node: nil)
        }
        
        let firstExpression: ExprSyntax = first.isEmpty ?
        ExprSyntax("") : ExprSyntax(referenceExpression(first))
        
        let expression = others.reduce(into: firstExpression) { expression, component in

            expression = ExprSyntax(MemberAccessExprSyntax(base: expression, declName: component))
        }
        
        guard let result = expression.as(MemberAccessExprSyntax.self) else {
            
            throw MacroError.internalError("Failed to generate a MemberAccessExprSyntax instance.", node: nil)
        }
        
        return result
    }
    
    static func expression(_ value: some StringProtocol) throws -> ExprSyntax {
        
        let components = value.split(separator: ".", omittingEmptySubsequences: false)
        
        guard components.count > 1 else {
            return ExprSyntax(referenceExpression(value))
        }
        
        return try ExprSyntax(memberAccessExpression(components))
    }
    
    static func labeledExpression(label: (some StringProtocol)? = nil, value: some ExprSyntaxProtocol) -> LabeledExprSyntax {
        
        LabeledExprSyntax(label: label?.description, expression: value)
    }
    
    static func labeledExpression(label: (some StringProtocol)? = nil, value: some StringProtocol) throws -> LabeledExprSyntax {
        
        try labeledExpression(label: label, value: expression(value))
    }

    static func labeledExpressions(_ expressions: some Sequence<LabeledExprSyntax>) -> LabeledExprListSyntax {
        
        LabeledExprListSyntax {

            for expression in expressions {
                expression
            }
        }
    }
    
    static func labeledExpressions(_ expressions: LabeledValues) throws -> LabeledExprListSyntax {

        let expressions = try expressions.map { label, value in
            try labeledExpression(label: label, value: value)
        }
        
        return labeledExpressions(expressions)
    }
}

public extension AttributeListSyntax {
    
    var names: [String] {
        
        casted.map { $0.name }
    }
}

public extension AttributeSyntax {
    
    var name: String {
        attributeName.trimmedDescription
    }
}

public extension EnumDeclSyntax {
    
    var attributeNames: [String] {
        attributes.names
    }
}

public extension StructDeclSyntax {
    
    var attributeNames: [String] {
        attributes.names
    }
}

public protocol NominalTypeSyntax {
    
    var name: TokenSyntax { get }
}

extension EnumDeclSyntax : NominalTypeSyntax {}
extension StructDeclSyntax : NominalTypeSyntax {}
extension ClassDeclSyntax : NominalTypeSyntax {}
extension ActorDeclSyntax : NominalTypeSyntax {}
extension ProtocolDeclSyntax : NominalTypeSyntax {}

public extension NominalTypeSyntax {
}

public protocol DiagnosableError : Error {
    
    var node: (any SyntaxProtocol)? { get }
}

public extension MacroExpansionContext {
    
    func diagnose(_ node: (some SyntaxProtocol)?, _ errorPredicate: () -> any Error) -> any Error {
        
        guard let node else {
            return errorPredicate()
        }
        
        let error = errorPredicate()
        addDiagnostics(from: error, node: node)
        
        return error
    }
}

public protocol VariableContainable {
    
    var memberBlock: MemberBlockSyntax { get }
}

public extension VariableContainable {
    
    var variables: [VariableDeclSyntax] {
        memberBlock.members.casted.compactMap { item in
            item.decl.as(VariableDeclSyntax.self)
        }
    }
}

extension EnumDeclSyntax : VariableContainable {}
extension StructDeclSyntax : VariableContainable {}
extension ClassDeclSyntax : VariableContainable {}
extension ActorDeclSyntax : VariableContainable {}
extension ProtocolDeclSyntax : VariableContainable {}

public extension PatternBindingListSyntax {
    
    var casted: [PatternBindingSyntax] {
        map { $0.as(PatternBindingSyntax.self)! }
    }
}

public extension PatternBindingSyntax {

    var identifier: TokenSyntax? {
        pattern.as(IdentifierPatternSyntax.self)?.identifier
    }
    
    var type: TypeSyntax? {
        typeAnnotation?.type.as(TypeSyntax.self)
    }
}

public extension TypeSyntax {
    
    var text: String {
        trimmedDescription
    }
}

public protocol AttributeContainable : SyntaxProtocol {
    
    var attributes: AttributeListSyntax { get }
}

extension FunctionDeclSyntax : AttributeContainable {}
extension VariableDeclSyntax : AttributeContainable {}
extension StructDeclSyntax : AttributeContainable {}
extension EnumDeclSyntax : AttributeContainable {}
extension ClassDeclSyntax : AttributeContainable {}
extension ActorDeclSyntax : AttributeContainable {}

public extension AttributeContainable {
    
    func findAttribute(by nameGroup: [String]) throws -> AttributeSyntax? {
        
        let attributes = attributes.casted.filter { nameGroup.contains($0.name) }
        
        guard attributes.count <= 1 else {
            throw MacroError.invalidAttributeDeclaration("A multiple of accessor type attributes found. (\(attributes.map(\.name))", node: self)
        }
        
        return attributes.first
    }
}

public extension LabeledExprSyntax {
    
    var stringLiteral: StringLiteralExprSyntax {
        
        get throws {
            
            guard let expression = expression.as(StringLiteralExprSyntax.self) else {
                
                throw MacroError.typeMismatch(expectedType: StringLiteralExprSyntax.self, actualType: type(of: expression), node: self)
            }
            
            return expression
        }
    }
}

public extension AttributeSyntax {
    
    var isAvailability: Bool {
        name == "available"
    }
    
    var availabilityArguments:  AvailabilityArgumentListSyntax {
        
        arguments?.as(AvailabilityArgumentListSyntax.self) ?? []
    }
}

public extension AvailabilityArgumentListSyntax {
    
    enum Item {
        case single(AvailabilityArgumentSyntax)
        case labeled(AvailabilityLabeledArgumentSyntax)
    }
    
    var casted: [Item] {
        
        get throws {

            try reduce(into: []) { partialResult, argument in
                
                if let argument = argument.as(AvailabilityArgumentSyntax.self) {
                    partialResult.append(.single(argument))
                    return
                }
                
                if let argument = argument.as(AvailabilityLabeledArgumentSyntax.self) {
                    partialResult.append(.labeled(argument))
                    return
                }
                
                throw MacroError.internalError("Unexpected argument found in availability attribute: \(argument.trimmedDescription)", node: self)
            }
        }
    }
}

public extension AvailabilityArgumentListSyntax.Item {
    
    var content: String {
        
        switch self {
            
        case .single(let argument):
            argument.argument.trimmedDescription
            
        case .labeled(let argument):
            argument.trimmedDescription
        }
    }
}

public extension TypeSyntax {
    
    var isFunction: Bool {
        `is`(FunctionTypeSyntax.self)
    }
}
