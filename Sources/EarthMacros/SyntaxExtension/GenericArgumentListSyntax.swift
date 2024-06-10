//
//  GenericArgumentListSyntax.swift
//
//  
//  Created by Tomohiro Kumagai on 2024/06/10
//  
//

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public extension GenericArgumentListSyntax {
    
    var casted: [GenericArgumentSyntax] {
        
        map {
            $0.as(GenericArgumentSyntax.self)!
        }
    }
}