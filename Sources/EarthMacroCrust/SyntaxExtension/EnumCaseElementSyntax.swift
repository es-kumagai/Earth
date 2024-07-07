//
//  EnumCaseElementSyntax.swift
//
//  
//  Created by Tomohiro Kumagai on 2024/07/07
//  
//

import SwiftSyntax
import SwiftSyntaxBuilder

public extension EnumCaseElementSyntax {
    
    var parameters: [EnumCaseParameterSyntax]? {
        parameterClause?.parameters.casted
    }
    
    var parameterCount: Int {
        parameterClause?.parameters.count ?? 0
    }
    
    var firstParameter: EnumCaseParameterSyntax? {
        parameterClause?.parameters.first
    }
}
