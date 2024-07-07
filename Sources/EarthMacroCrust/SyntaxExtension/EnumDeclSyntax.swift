//
//  EnumDeclSyntax.swift
//
//  
//  Created by Tomohiro Kumagai on 2024/06/11
//  
//

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public extension EnumDeclSyntax {
    
    var allCases: [EnumCaseDeclSyntax] {

        memberBlock.members.casted.compactMap { item in
            item.decl.as(EnumCaseDeclSyntax.self)
        }
    }
    
    var allCaseElements: [EnumCaseElementSyntax] {
        
        allCases.flatMap { list in
            list.caseElements
        }
    }
}

public extension Sequence<EnumDeclSyntax> {
    
    func first(withTypeName name: some StringProtocol) -> EnumDeclSyntax? {
        
        first { enumeration in
            enumeration.name.text == name
        }
    }
}
