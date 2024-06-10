//
//  AttributeSyntax.swift
//
//  
//  Created by Tomohiro Kumagai on 2024/06/10
//  
//

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public extension AttributeSyntax {
    
    var attributeIdentifier: IdentifierTypeSyntax? {
        attributeName.as(IdentifierTypeSyntax.self)
    }

    func having(_ identifier: IdentifierTypeSyntax) -> Bool {
        attributeIdentifier?.name.text == identifier.name.text
    }
}
