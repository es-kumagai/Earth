//
//  StringLiteralExprSyntax.swift
//
//  
//  Created by Tomohiro Kumagai on 2024/06/11
//  
//

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public extension StringLiteralExprSyntax {

    var text: String {
        segments.trimmedDescription
    }
}
