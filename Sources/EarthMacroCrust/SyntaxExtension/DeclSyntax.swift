//
//  DeclSyntax.swift
//
//  
//  Created by Tomohiro Kumagai on 2024/07/07
//  
//

import SwiftSyntax

public extension Sequence where Element == EnumDeclSyntax {
    
    consuming func named(_ name: some StringProtocol) -> [Element] {
        
        filter {
            $0.name.text == name
        }
    }
}

public extension Sequence where Element == StructDeclSyntax {
    
    consuming func named(_ name: some StringProtocol) -> [Element] {
        
        filter {
            $0.name.text == name
        }
    }
}

public extension Sequence where Element == ClassDeclSyntax {
    
    consuming func named(_ name: some StringProtocol) -> [Element] {
        
        filter {
            $0.name.text == name
        }
    }
}

public extension Sequence where Element == ActorDeclSyntax {
    
    consuming func named(_ name: some StringProtocol) -> [Element] {
        
        filter {
            $0.name.text == name
        }
    }
}

public extension Sequence where Element == TypeAliasDeclSyntax {
    
    consuming func named(_ name: some StringProtocol) -> [Element] {
        
        filter {
            $0.name.text == name
        }
    }
}

public extension Sequence where Element == AssociatedTypeDeclSyntax {
    
    consuming func named(_ name: some StringProtocol) -> [Element] {
        
        filter {
            $0.name.text == name
        }
    }
}
