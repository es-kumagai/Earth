//
//  TokenSyntax.swift
//
//  
//  Created by Tomohiro Kumagai on 2024/06/11
//  
//

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public extension TokenSyntax {
    
    var uppercasedFirstLetter: TokenSyntax {
        
        "\(raw: text.stringWithUppercasedFirstLetter)"
    }
    
    var unbackticked: TokenSyntax {
        
        let text = text
        
        guard text.count >= 2, text.first == "`" && text.last == "`" else {
            return self
        }
        
        return "\(raw: text.dropFirst().dropLast())"
    }
    
    func prefixed(with prefix: some StringProtocol, uppercasedFirstLetter: Bool) -> TokenSyntax {
        
        "\(raw: prefix)\(raw: uppercasedFirstLetter ? text.stringWithUppercasedFirstLetter : text)"
    }
}
