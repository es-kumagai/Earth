//
//  RawRepresentingError.swift
//
//  
//  Created by Tomohiro Kumagai on 2024/06/09
//  
//

public enum RawRepresentingError : Error {
    
    case unsupported(String)
    case unexpectedSyntax(String)
}

extension RawRepresentingError : CustomStringConvertible {
    
    public var description: String {
        
        switch self {
            
        case .unsupported(let reason):
            "Unsupported error: \(reason)"
            
        case .unexpectedSyntax(let reason):
            "Syntax error: \(reason)"
        }
    }
}
