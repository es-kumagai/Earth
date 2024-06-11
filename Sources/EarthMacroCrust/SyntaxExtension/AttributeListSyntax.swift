//
//  AttributeListSyntax.swift
//
//  
//  Created by Tomohiro Kumagai on 2024/06/10
//  
//

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public extension AttributeListSyntax {
    
    var casted: [AttributeSyntax] {
        
        map {
            $0.as(AttributeSyntax.self)!
        }
    }

    func first(having identifier: borrowing IdentifierTypeSyntax) -> AttributeSyntax? {
        
        casted.first {
            $0.having(identifier)
        }
    }
}
