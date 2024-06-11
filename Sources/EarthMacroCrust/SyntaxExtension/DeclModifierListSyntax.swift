//
//  DeclModifierListSyntax.swift
//
//  
//  Created by Tomohiro Kumagai on 2024/06/10
//  
//

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public extension DeclModifierListSyntax {
    
    private static let primaryAccessControlNames: Set = [
        "open",
        "public",
        "module",
        "internal",
        "fileprivate",
        "private",
    ]
    
    init(_ names: String...) {
        
        self.init {
            for name in names {
                DeclModifierSyntax(name: "\(raw: name)")
            }
        }
    }
    
    var casted: [DeclModifierSyntax] {
        
        map {
            $0.as(DeclModifierSyntax.self)!
        }
    }
    
    var primaryAccessControl: DeclModifierSyntax? {

        accessControls.first
    }
        
    var accessControls: DeclModifierListSyntax {

        let accessControlNames = Self.primaryAccessControlNames.intersection(casted.map(\.name.text))
        guard !accessControlNames.isEmpty else {
            return []
        }
        
        return DeclModifierListSyntax {
            
            for name in accessControlNames {
                DeclModifierSyntax(name: "\(raw: name)")
            }
        }
    }
}
