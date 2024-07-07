//
//  ExprSyntax.swift
//
//  
//  Created by Tomohiro Kumagai on 2024/07/07
//  
//

import SwiftSyntax

public extension ExprSyntax {
    
    func asArray<Syntax: ExprSyntaxProtocol>(of syntaxType: Syntax.Type) throws -> [Syntax]? {
        
        guard let elements = self.as(ArrayExprSyntax.self)?.casted else {
            return nil
        }

        var syntaxes: [Syntax] = []
        
        for element in elements.map(\.expression) {
            
            guard let element = element.as(Syntax.self) else {
                return nil
            }
            
            syntaxes.append(element)
        }
        
        return syntaxes
    }
}
