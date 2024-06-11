//
//  String.swift
//
//  
//  Created by Tomohiro Kumagai on 2024/06/07
//  
//

public extension StringProtocol {
    
    var stringWithUppercasedFirstLetter: String {
        
        guard !isEmpty else {
            return ""
        }

        let text = description
        
        return "\(text.first!.uppercased())\(text.dropFirst())"
    }
}
