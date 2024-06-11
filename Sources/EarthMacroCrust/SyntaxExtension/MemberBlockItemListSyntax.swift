//
//  MemberBlockItemListSyntax.swift
//
//  
//  Created by Tomohiro Kumagai on 2024/06/11
//  
//

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public extension MemberBlockItemListSyntax {
    
    var casted: [MemberBlockItemSyntax] {
        
        map {
            $0.as(MemberBlockItemSyntax.self)!
        }
    }
}
