//
//  LabeledExprSyntax.swift
//
//  
//  Created by Tomohiro Kumagai on 2024/06/11
//  
//

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public extension LabeledExprSyntax {
    
}

public extension Sequence<LabeledExprSyntax> {
    
    func first(havingName name: String?) -> LabeledExprSyntax? {
        
        first { expr in
            expr.label?.text == name
        }
    }
}
