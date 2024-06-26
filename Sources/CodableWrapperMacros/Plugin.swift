import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct CodableWrapperPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        Codable.self,
        SwiftDataCodable.self,
        CodableSubclass.self,
        CodingKey.self,
        CodingNestedKey.self,
        CodingTransformer.self,
        CodingKeyIgnored.self,
    ]
}
