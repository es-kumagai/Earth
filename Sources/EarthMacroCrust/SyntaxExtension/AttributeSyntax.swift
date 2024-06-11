//
//  AttributeSyntax.swift
//
//  
//  Created by Tomohiro Kumagai on 2024/06/10
//  
//

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
    
    var parameters: [LabeledExprSyntax]? {
        
        guard let arguments else {
            return nil
        }

        return arguments.as(LabeledExprListSyntax.self)?.casted
    }
}
