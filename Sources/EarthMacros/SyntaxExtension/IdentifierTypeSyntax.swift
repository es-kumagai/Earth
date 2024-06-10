//
//  IdentifierTypeSyntax.swift
//  
//  
//  Created by Tomohiro Kumagai on 2024/06/10
//  
//

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public extension IdentifierTypeSyntax {
    
    var genericArguments: GenericArgumentListSyntax? {
        
        genericArgumentClause?.arguments
    }
}
