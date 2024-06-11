//
//  DeclGroupSyntax.swift
//  
//  
//  Created by Tomohiro Kumagai on 2024/06/10
//  
//

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public extension DeclGroupSyntax {
    
    func `is`<each Syntax>(either syntax: repeat (each Syntax).Type) -> Bool where repeat each Syntax : SyntaxProtocol {
        
        // FIXME: Rewrite using for-in-repeat syntax in Swift 6.
        func makeCheckerFunction(for type: (some SyntaxProtocol).Type) -> () -> Bool {
            
            {
                self.is(type)
            }
        }
        
        var checkerFunctions: [() -> Bool] = []
        
        repeat checkerFunctions.append(makeCheckerFunction(for: each syntax))
        
        for checkerFunction in checkerFunctions {
            
            if checkerFunction() {
                return true
            }
        }
        
        return false
    }
}
