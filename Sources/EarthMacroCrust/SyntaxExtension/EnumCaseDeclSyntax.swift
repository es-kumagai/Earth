//
//  EnumCaseDeclSyntax.swift
//
//  
//  Created by Tomohiro Kumagai on 2024/06/11
//  
//

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public extension EnumCaseDeclSyntax {
    
    var caseElements: [EnumCaseElementSyntax] {

        elements.map { $0 }
    }
}
