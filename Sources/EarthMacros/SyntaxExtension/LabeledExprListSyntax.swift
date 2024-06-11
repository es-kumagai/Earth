//
//  LabeledExprListSyntax.swift
//
//  
//  Created by Tomohiro Kumagai on 2024/06/11
//  
//

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public extension LabeledExprListSyntax {

    var casted: [LabeledExprSyntax] {
        
        map { $0.as(LabeledExprSyntax.self)! }
    }
}
