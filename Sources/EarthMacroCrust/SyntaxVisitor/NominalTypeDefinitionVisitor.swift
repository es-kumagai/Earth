//
//  NominalTypeDefinitionVisitor.swift
//
//  
//  Created by Tomohiro Kumagai on 2024/07/07
//  
//

import SwiftSyntax

public final class NominalTypeDefinitionVisitor : SyntaxVisitor {

    public typealias VisitCallback = (DeclSyntaxProtocol) -> SyntaxVisitorContinueKind
    
    public let visitCallback: VisitCallback
    
    public init(viewMode: SyntaxTreeViewMode, visitCallback: @escaping VisitCallback) {
        
        self.visitCallback = visitCallback
        
        super.init(viewMode: viewMode)
    }
    
    public override func visit(_ node: StructDeclSyntax) -> SyntaxVisitorContinueKind {
        visitCallback(node)
    }
    
    public override func visit(_ node: ClassDeclSyntax) -> SyntaxVisitorContinueKind {
        visitCallback(node)
    }
    
    public override func visit(_ node: EnumDeclSyntax) -> SyntaxVisitorContinueKind {
        visitCallback(node)
    }
    
    public override func visit(_ node: ActorDeclSyntax) -> SyntaxVisitorContinueKind {
        visitCallback(node)
    }
}
