import SwiftSyntax
import SwiftSyntaxMacros

public struct SwiftDataCodable: ExtensionMacro, MemberMacro {
    public static func expansion(of node: AttributeSyntax,
                                 attachedTo declaration: some DeclGroupSyntax,
                                 providingExtensionsOf type: some TypeSyntaxProtocol,
                                 conformingTo protocols: [TypeSyntax], in context: some MacroExpansionContext) throws -> [ExtensionDeclSyntax] {
        var inheritedTypes: InheritedTypeListSyntax?
        if let declaration = declaration.as(StructDeclSyntax.self) {
            inheritedTypes = declaration.inheritanceClause?.inheritedTypes
        } else if let declaration = declaration.as(ClassDeclSyntax.self) {
            inheritedTypes = declaration.inheritanceClause?.inheritedTypes
        } else {
            throw ASTError("use @SwiftDataCodable in `struct` or `class`")
        }
        if let inheritedTypes,
           inheritedTypes.contains(where: { inherited in inherited.type.trimmedDescription == "Codable" }) {
            return []
        }

        let ext: DeclSyntax =
            """
            extension \(type.trimmed): Codable {}
            """

        return [ext.cast(ExtensionDeclSyntax.self)]
    }

    public static func expansion(of node: SwiftSyntax.AttributeSyntax,
                                 providingMembersOf declaration: some SwiftSyntax.DeclGroupSyntax,
                                 in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.DeclSyntax] {
        // TODO: diagnostic do not implement `init(from:)` or `encode(to:))`

        let propertyContainer = try ModelMemberPropertyContainer(decl: declaration, context: context)
        let decoder = try propertyContainer.genDecoderInitializer(config: .init(isOverride: false, swiftDataMode: true))
        let encoder = try propertyContainer.genEncodeFunction(config: .init(isOverride: false, swiftDataMode: true))

        var hasWiseInit = true
        if case let .argumentList(list) = node.arguments, list.first?.expression.description == "false" {
            hasWiseInit = false
        }

        if !hasWiseInit {
            return [decoder, encoder]
        } else {
            let memberwiseInit = try propertyContainer.genMemberwiseInit(config: .init(isOverride: false, swiftDataMode: true))
            return [decoder, encoder, memberwiseInit]
        }
    }
}
