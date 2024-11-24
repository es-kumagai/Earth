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
        
        guard isBackticked else {
            return self
        }
        
        return "\(raw: text.dropFirst().dropLast())"
    }
    
    var isBackticked: Bool {
        text.count >= 2 && text.first == "`" && text.last == "`"
    }
    
    func prefixed(with prefix: some StringProtocol, uppercasedFirstLetter: Bool) -> TokenSyntax {
        
        "\(raw: prefix)\(raw: uppercasedFirstLetter ? text.stringWithUppercasedFirstLetter : text)"
    }
}
