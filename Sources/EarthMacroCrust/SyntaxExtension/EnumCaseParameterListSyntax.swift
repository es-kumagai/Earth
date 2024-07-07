//
//  EnumCaseParameterListSyntax.swift
//
//  
//  Created by Tomohiro Kumagai on 2024/07/07
//  
//

import SwiftSyntax
import SwiftSyntaxBuilder

public extension EnumCaseParameterListSyntax {
    
    var casted: [EnumCaseParameterSyntax] {
        
        map {
            $0.as(EnumCaseParameterSyntax.self)!
        }
    }
}
