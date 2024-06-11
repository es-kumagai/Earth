//
//  MemberBlockSyntax.swift
//
//  
//  Created by Tomohiro Kumagai on 2024/06/11
//  
//

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public extension MemberBlockSyntax {

    var enumerations: [EnumDeclSyntax] {
        
        members.casted
            .compactMap { item in
                item.decl.as(EnumDeclSyntax.self)
            }
    }
}
