import SwiftSyntax
import SwiftSyntaxMacros

enum CodableEndKind {
    case decode
    case encode

    var macroName: String {
        switch self {
        case .decode: "DecodeEnd"
        case .encode: "EncodeEnd"
        }
    }

    func validate(_ declaration: some DeclSyntaxProtocol) throws -> FunctionDeclSyntax {
        guard let function = declaration.as(FunctionDeclSyntax.self) else {
            throw ASTError("@\(macroName) can only be applied to a method declaration.")
        }
        guard function.signature.parameterClause.parameters.isEmpty else {
            throw ASTError("@\(macroName) method '\(function.name.text)' must not have parameters.")
        }
        guard function.signature.effectSpecifiers?.asyncSpecifier == nil else {
            throw ASTError("@\(macroName) method '\(function.name.text)' must not be async.")
        }
        guard !function.modifiers.contains(where: { $0.name.text == "static" || $0.name.text == "class" }) else {
            throw ASTError("@\(macroName) method '\(function.name.text)' must be an instance method.")
        }
        return function
    }
}

public struct DecodeEnd: PeerMacro {
    public static func expansion(of node: AttributeSyntax,
                                 providingPeersOf declaration: some DeclSyntaxProtocol,
                                 in context: some MacroExpansionContext) throws -> [DeclSyntax] {
        _ = try CodableEndKind.decode.validate(declaration)
        return []
    }
}

public struct EncodeEnd: PeerMacro {
    public static func expansion(of node: AttributeSyntax,
                                 providingPeersOf declaration: some DeclSyntaxProtocol,
                                 in context: some MacroExpansionContext) throws -> [DeclSyntax] {
        _ = try CodableEndKind.encode.validate(declaration)
        return []
    }
}
