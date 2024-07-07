//
//  MacroError.swift
//
//  
//  Created by Tomohiro Kumagai on 2024/07/07
//  
//

import SwiftSyntax

public enum MacroError : Error {
    
    case attachedToUnexpectedType(String, node: Node)
    case unexpectedTypeName(String, node: Node)
    case unexpectedTypeAliasName(String, node: Node)
    case notSufficientDefinition(String, node: Node)
    case invalidTypeAliasDeclaration(String, node: Node)
    case invalidEnumCaseDeclaration(String, node: Node)
    case invalidEnumCaseInitialValue(String, node: Node)
    case invalidVariableDeclaration(String, node: Node)
    case invalidAttributeDeclaration(String, node: Node)
    case typeCannotBeGenerate(String)
    case invalidParameter(String, node: Node?)
    case internalError(String, node: Node?)
    case typeMismatch(expectedType: Any.Type, actualType: Any.Type, node: Node?)
}

extension MacroError : DiagnosableError {
    
    public typealias Node = any SyntaxProtocol
    
    public var node: Node? {
        
        switch self {
            
        case
                .attachedToUnexpectedType(_, node: let node),
                .unexpectedTypeName(_, node: let node),
                .unexpectedTypeAliasName(_, node: let node),
                .notSufficientDefinition(_, node: let node),
                .invalidTypeAliasDeclaration(_, node: let node),
                .invalidEnumCaseDeclaration(_, node: let node),
                .invalidEnumCaseInitialValue(_, node: let node),
                .invalidVariableDeclaration(_, node: let node),
                .invalidParameter(_, node: let node?),
                .invalidAttributeDeclaration(_, node: let node),
                .internalError(_, node: let node?),
                .typeMismatch(_, _, node: let node?):
            return node
            
        case
                .invalidParameter(_, node: nil),
                .internalError(_, node: nil),
                .typeCannotBeGenerate(_),
                .typeMismatch(_, _, nil):
            return nil
        }
    }
}
