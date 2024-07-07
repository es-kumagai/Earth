//
//  ArrayExprSyntax.swift
//
//  
//  Created by Tomohiro Kumagai on 2024/07/07
//  
//

import SwiftSyntax

public extension ArrayExprSyntax {
    
    var casted: [ArrayElementSyntax] {
        elements.map { $0.as(ArrayElementSyntax.self)! }
    }
}
