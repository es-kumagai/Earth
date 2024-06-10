//
//  RawRepresentingType.swift
//
//  
//  Created by Tomohiro Kumagai on 2024/06/07
//  
//

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct RewritableRawRepresenting : RawRepresentingProtocol {
    
    public static var attributeIdentifer = IdentifierTypeSyntax(name: "RewritableRawRepresenting")
    
    public static var rawValueModifier: ExprSyntax = "var"
}

public struct RawRepresenting : RawRepresentingProtocol {
    
    public static var attributeIdentifer = IdentifierTypeSyntax(name: "RawRepresenting")
    
    public static var rawValueModifier: ExprSyntax = "let"
}
