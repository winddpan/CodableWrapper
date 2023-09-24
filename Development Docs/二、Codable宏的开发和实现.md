*接上一章 CodableWrapper Macro 版的 [设计目标和手动实现这些目标特性](https://juejin.cn/post/7251501945272270908)，本章节主要讲Codable宏的开发和实现。*

## 搭建环境
1. 目前Swift5.9还在Beta阶段
2. 下载 Xcode15 Beta 或者更之后的版本
3. 从swift.org下载安装Swift 5.9 Development for Xcode [Snapshot](https://www.swift.org/download/#snapsh)
4. 打开Xcode15，File -> New -> Package -> Swift Macro，项目名为CodableWrapper
5. Xcode会自动拉取swift-syntax依赖，整个项目自动生成3个target和一个Tests，4个目录，分别为：
   1. Sources/CodableWrapper Package库目录，用于存放宏定义，以及库提供的一些API和实现。
   2. Sources/CodableWrapperClient 本地测试运行使用，本文使用TDD方式，所以不需要它
   3. Sources/CodableWrapperMacros 宏实现的地方
   4. Tests/CodableWrapperTests 宏的测试用例

## 改造Package.Swift
因为使用TDD方式开发，开发和测试用例都基于Tests。删除CodableWrapperClient，CodableWrapperTests依赖改为CodableWrapper这个framework而不是CodableWrapperMacros。

```
let package = Package(
    name: "CodableWrapper",
    platforms: [.macOS(.v10_15), .iOS(.v13), .tvOS(.v13), .watchOS(.v6), .macCatalyst(.v13)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "CodableWrapper",
            targets: ["CodableWrapper"]
        ),
    ],
    dependencies: [
        // Depend on the latest Swift 5.9 prerelease of SwiftSyntax
        .package(url: "https://github.com/apple/swift-syntax.git", from: "509.0.0-swift-5.9-DEVELOPMENT-SNAPSHOT-2023-04-25-b"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        // Macro implementation that performs the source transformation of a macro.
        .macro(
            name: "CodableWrapperMacros",
            dependencies: [
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
            ]
        ),

        // Library that exposes a macro as part of its API, which is used in client programs.
        .target(name: "CodableWrapper", dependencies: ["CodableWrapperMacros"]),

        // A test target used to develop the macro implementation.
        .testTarget(
            name: "CodableWrapperTests",
            dependencies: [
                "CodableWrapper",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
            ]
        ),
    ]
)
```

## 先写一个基本测试用例：

```
// CodableWrapperTests.swift

@Codable
struct BasicModel {
    var defaultVal: String = "hello world"
    var strict: String
    var noStrict: String?
    var autoConvert: Int?

    @CodingKey("customKey")
    var codingKeySupport: String
}

final class CodableWrapperTests: XCTestCase {
    func testBasicExample() throws {
        let jsonStr = """
        {"strict": "value of strict", "autoConvert": "998", "customKey": "value of customKey"}
        """

        let model = try JSONDecoder().decode(BasicModel.self, from: jsonStr.data(using: .utf8)!)
        XCTAssertEqual(model.defaultVal, "hello world")
        XCTAssertEqual(model.strict, "value of strictValue")
        XCTAssertEqual(model.noStrict, nil)
        XCTAssertEqual(model.autoConvert, 998)
        XCTAssertEqual(model.codingKeySupport, "value of customKey")
    }
}
```

## Swift Macro 的一些基本概念
这里推荐一篇掘金的文章、Swift Macro提议发起者的demo、一个Swift AST解析工具（下面会经常用到）
1. [【WWDC23】一文看懂 Swift Macro](https://juejin.cn/post/7249888320166903867)
2. [swift-macro-examples](https://github.com/DougGregor/swift-macro-examples)
3. [Swift AST Explorer](https://swift-ast-explorer.com/)

本项目使用了`@attached(member)`和`@attached(conformance)`两种类型的宏

## 简单定义宏和过编译

测试用例很明显编译会报错，先定义Codable和CodingKey宏。

```
// CodableWrapperMacros/CodableWrapper.swift

@attached(member, names: named(init(from:)), named(encode(to:)))
@attached(conformance)
public macro Codable() = #externalMacro(module: "CodableWrapperMacros", type: "Codable")

@attached(member)
public macro CodingKey(_ key: String ...) = #externalMacro(module: "CodableWrapperMacros", type: "CodingKey")
```

实现@Codable和@CodingKey宏。

```
// CodableWrapperMacros/Codable.swift
import SwiftSyntax
import SwiftSyntaxMacros

public struct Codable: MemberMacro {
    public static func expansion(of _: AttributeSyntax,
                                 providingConformancesOf declaration: some DeclGroupSyntax,
                                 in _: some MacroExpansionContext) throws -> [(TypeSyntax, GenericWhereClauseSyntax?)]
    {
        return []
    }

    public static func expansion(of node: SwiftSyntax.AttributeSyntax,
                                 providingMembersOf declaration: some SwiftSyntax.DeclGroupSyntax,
                                 in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.DeclSyntax]
    {
        return []
    }
}
```

```
// CodableWrapperMacros/CodingKey.swift
import SwiftSyntax
import SwiftSyntaxMacros

public struct CodingKey: ConformanceMacro, MemberMacro {
    public static func expansion(of node: SwiftSyntax.AttributeSyntax,
                                 providingMembersOf declaration: some SwiftSyntax.DeclGroupSyntax,
                                 in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.DeclSyntax]
    {
        return []
    }
}
```

```
// CodableWrapperMacros/Plugin.swift
import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct CodableWrapperPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        Codable.self,
        CodingKey.self,
    ]
}
```

如果你还不了解宏的各种类型，我建议先阅读这篇文章：[【WWDC23】一文看懂 Swift Macro](https://juejin.cn/post/7249888320166903867)。

在这里，`@Codable`实现了两种宏，一种是一致性宏（Conformance Macro），另一种是成员宏（Member Macro）。

一些关于这些宏的说明：
- `@Codable`和`Codable`协议的宏名不会冲突，这样的命名一致性可以降低认知负担。
- Conformance Macro用于自动让数据模型遵循Codable协议（如果尚未遵循）。
- Member Macro用于添加`init(from decoder: Decoder)`和`func encode(to encoder: Encoder)`这两个方法。在`@attached(member, named(init(from:)), named(encode(to:)))`中，必须声明新增方法的名称才是合法的。

运行测试用例，按下Command+U，编译通过了，但是测试用例很明显会失败。因为Codable不支持使用默认值的方式，所以无法找到`defaultValue`这个key。

### 实现自动遵循Codable协议
```
// CodableWrapperMacros/Codable.swift

public struct Codable: ConformanceMacro, MemberMacro {
    public static func expansion(of node: AttributeSyntax,
                                 providingConformancesOf declaration: some DeclGroupSyntax,
                                 in context: some MacroExpansionContext) throws -> [(TypeSyntax, GenericWhereClauseSyntax?)] {
        return [("Codable", nil)]
    }

        public static func expansion(of node: SwiftSyntax.AttributeSyntax,
                                 providingMembersOf declaration: some SwiftSyntax.DeclGroupSyntax,
                                 in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.DeclSyntax]
    {
        return []
    }
}
```

编译一下。右键`@Codable` -> `Expand Macro`查看扩写的代码，看起来还不错。
![20230704155615](http://images.testfast.cn/20230704155615.png)
![20230704155520](http://images.testfast.cn/20230704155520.png)

但如果`BasicModel`本身就遵循了`Codable`，编译就报错了。所以希望先检查数据模型是否遵循`Codable`协议，如果没有的话再遵循它，怎么办呢？
打开[Swift AST Explorer ](https://swift-ast-explorer.com/)编写一个简单`Struct`和`Class`，可以看到整个AST，`declaration: some DeclGroupSyntax`对象根据模型是`struct`还是`class`分别对应了`StructDecl`和`ClassDecl`。

![20230704160841](http://images.testfast.cn/20230704160841.png)

一番探究，补上检查代码如下。

```
public static func expansion(of node: AttributeSyntax,
                                providingConformancesOf declaration: some DeclGroupSyntax,
                                in context: some MacroExpansionContext) throws -> [(TypeSyntax, GenericWhereClauseSyntax?)] {
    var inheritedTypes: InheritedTypeListSyntax?
    if let declaration = declaration.as(StructDeclSyntax.self) {
        inheritedTypes = declaration.inheritanceClause?.inheritedTypeCollection
    } else if let declaration = declaration.as(ClassDeclSyntax.self) {
        inheritedTypes = declaration.inheritanceClause?.inheritedTypeCollection
    } else {
        throw ASTError("use @Codable in `struct` or `class`")
    }
    if let inheritedTypes = inheritedTypes,
        inheritedTypes.contains(where: { inherited in inherited.typeName.trimmedDescription == "Codable" })
    {
        return []
    }
    return [("Codable" as TypeSyntax, nil)]
}
```
这里顺便检查了一下是否是 `class` 或 `struct`，如果不是则会提示。

![20230704175012](http://images.testfast.cn/20230704175012.png)

至此，第一个 Macro 编写流程已经跑通。

### 新增 Macro `@CodingNestedKey` `@CodingTransformer` 和丰富测试用例
根据上一章的[设计目标和手动实现这些目标特性](https://juejin.cn/post/7251501945272270908)确定了目标和手动实现。
- 目标如下：
   1. 支持缺省值，JSON 缺少字段容错
   2. 支持 String Bool Number 等基本类型互转
   3. 驼峰大小写自动互转
   4. 自定义解析 key
   5. 自定义解析规则 (Transformer)
   6. 方便的 Codable Class 子类

为了达成目标，新增 Macro `@CodingNestedKey` `@CodingTransformer` 和完善测试用例。这两个 Macro 的声明和实现同上面的 `@CodingKey` 一致。
```
@Codable
struct BasicModel {
    var defaultVal: String = "hello world"
    var defaultVal2: String = Bool.random() ? "hello world" : ""
    let strict: String
    let noStrict: String?
    let autoConvert: Int?

    @CodingKey("hello")
    var hi: String = "there"

    @CodingNestedKey("nested.hi")
    @CodingTransformer(StringPrefixTransform("HELLO -> "))
    var codingKeySupport: String

    @CodingNestedKey("nested.b")
    var nestedB: String
```


### 实现 `@Codable` 功能
根据上一章的[设计目标和手动实现这些目标特性](https://juejin.cn/post/7251501945272270908)确定了目标和手动实现。

先定义个 `ModelMemberPropertyContainer`，`init(from decoder: Decoder)` 和 `func encode(to encoder: Encoder)` 的扩展都在里面实现。

```
public static func expansion(of node: SwiftSyntax.AttributeSyntax,
                                providingMembersOf declaration: some SwiftSyntax.DeclGroupSyntax,
                                in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.DeclSyntax]
{
    let propertyContainer = try ModelMemberPropertyContainer(decl: declaration, context: context)
    let decoder = try propertyContainer.genDecoderInitializer(config: .init(isOverride: false))
    let encoder = try propertyContainer.genEncodeFunction(config: .init(isOverride: false))
    return [decoder, encoder]
}
```

```
// CodableWrapperMacros/ModelMemberPropertyContainer.swift

import SwiftSyntax
import SwiftSyntaxMacros

struct GenConfig {
    let isOverride: Bool
}

struct ModelMemberPropertyContainer {
    let context: MacroExpansionContext
    fileprivate let decl: DeclGroupSyntax

    init(decl: DeclGroupSyntax, context: some MacroExpansionContext) throws {
        self.decl = decl
        self.context = context
    }

    func genDecoderInitializer(config: GenConfig) throws -> DeclSyntax {
        return """
        init(from decoder: Decoder) throws {
            fatalError()
        }
        """ as DeclSyntax
    }

    func genEncodeFunction(config: GenConfig) throws -> DeclSyntax {
        return """
        func encode(to encoder: Encoder) throws {
            fatalError()
        }
        """ as DeclSyntax
    }
}

```
[查看ModelMemberPropertyContainer完整源码](https://github.com/winddpan/CodableWrapper/blob/swift5.9-macro/Sources/CodableWrapperMacros/ModelMemberPropertyContainer.swift)

简单实现了框架，编译并查看一下扩写的代码。

![20230704170239](http://images.testfast.cn/20230704170239.png)

#### 填充`init(from decoder: Decoder)`
根据上一章的[设计目标和手动实现这些目标特性](https://juejin.cn/post/7251501945272270908)，我们已经封装好了`container.decode(type:keys:nestedKeys:)`和`container.encode(type:keys:nestedKeys:)`。希望将`BasicModel`扩展为以下形式：
```
@Codable
struct BasicModel {
    var defaultVal: String = "hello world"
    var defaultVal2: String = Bool.random() ? "hello world" : ""
    let strict: String
    let noStrict: String?
    let autoConvert: Int?

    @CodingKey("hello")
    var hi: String = "there"

    @CodingNestedKey("nested.hi")
    @CodingTransformer(StringPrefixTransform("HELLO -> "))
    var codingKeySupport: String

    @CodingNestedKey("nested.b")
    var nestedB: String

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: AnyCodingKey.self)

        self.defaultVal = (try? container.decode(type: type(of: self.defaultVal), keys: ["defaultVal"], nestedKeys: [])) ?? ("hello world")
        self.defaultVal2 = (try? container.decode(type: type(of: self.defaultVal2), keys: ["defaultVal2"], nestedKeys: [])) ?? (Bool.random() ? "hello world" : "")
        self.strict = try container.decode(type: type(of: self.strict), keys: ["strict"], nestedKeys: [])
        self.noStrict = try container.decode(type: type(of: self.noStrict), keys: ["noStrict"], nestedKeys: [])
        self.autoConvert = try container.decode(type: type(of: self.autoConvert), keys: ["autoConvert"], nestedKeys: [])
        self.hi = (try? container.decode(type: type(of: self.hi), keys: ["hello", "hi"], nestedKeys: [])) ?? ("there")

        let transformer = StringPrefixTransform("HELLO -> ")
        let codingKeySupport = try? container.decode(type: type(of: transformer).JSON.self, keys: ["codingKeySupport"], nestedKeys: ["nested.hi"])
        self.codingKeySupport = transformer.transformFromJSON(codingKeySupport)

        self.nestedB = try container.decode(type: type(of: self.nestedB), keys: ["nestedB"], nestedKeys: ["nested.b"])
    }
}
```

这里使用`type(of: self.defaultVal)`而不是`String`是因为如果这样定义`var defaultVal = "hello world"`，就无法在AST阶段获取类型，需要到语义分析阶段才行。感谢编译器优化，`type(of: self.defaultVal)`会自动在之后的阶段被正确转换为`String.self`（测试一下`type(of: self.strict)`在`self.strict`未初始化的时候也能被编译过）。为了获取`Transformer`的源类型，也同样使用`type(of: \(transformerVar)).JSON.self`。

分析一下希望生成的代码：需要得知属性名、`@CodingKey`的参数、`@CodingNestedKey`的参数、`@CodingTransformer`的参数、初始化表达式。设计一个结构体：
```
private struct ModelMemberProperty {
    var name: String
    var type: String
    var isOptional: Bool = false
    var normalKeys: [String] = []
    var nestedKeys: [String] = []
    var transformerExpr: String?
    var initializerExpr: String?
}
```
`transformerExpr`和`initializerExpr`都是表达式，因为参数可能是一个实例对象，也可能是整个构造方法。我们要做的只是把它原封不动地塞过去。

```
func genDecoderInitializer(config: GenConfig) throws -> DeclSyntax {
    // memberProperties: [ModelMemberProperty]
    let body = memberProperties.enumerated().map { idx, member in

        if let transformerExpr = member.transformerExpr {
            let transformerVar = context.makeUniqueName(String(idx))
            let tempJsonVar = member.name

            var text = """
            let \(transformerVar) = \(transformerExpr)
            let \(tempJsonVar) = try? container.decode(type: type(of: \(transformerVar)).JSON.self, keys: [\(member.codingKeys.joined(separator: ", "))], nestedKeys: [\(member.nestedKeys.joined(separator: ", "))])
            """

            if let initializerExpr = member.initializerExpr {
                text.append("""
                self.\(member.name) = \(transformerVar).transformFromJSON(\(tempJsonVar), fallback: \(initializerExpr))
                """)
            } else {
                text.append("""
                self.\(member.name) = \(transformerVar).transformFromJSON(\(tempJsonVar))
                """)
            }

            return text
        } else {
            let body = "container.decode(type: type(of: self.\(member.name)), keys: [\(member.codingKeys.joined(separator: ", "))], nestedKeys: [\(member.nestedKeys.joined(separator: ", "))])"

            if let initializerExpr = member.initializerExpr {
                return "self.\(member.name) = (try? \(body)) ?? (\(initializerExpr))"
            } else {
                return "self.\(member.name) = try \(body)"
            }
        }
    }
    .joined(separator: "\n")

    let decoder: DeclSyntax = """
    \(raw: attributesPrefix(option: [.public, .required]))init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: AnyCodingKey.self)
        \(raw: body)
    }
    """

    return decoder
}
```

* ```let transformerVar = context.makeUniqueName(String(idx))```
  需要生成一个局部transformer变量，为了防止变量名冲突使用了`makeUniqueName`生成唯一变量名
  
* `attributesPrefix(option: [.public, .required])`
  根据 struct/class 是 open/public 生成正确的修饰。所有情况展开如下：
  
    ```
    open class Model: Codable {
        public required init(from decoder: Decoder) throws {}
    }

    public class Model: Codable {
        public required init(from decoder: Decoder) throws {}
    }

    class Model: Codable {
        required init(from decoder: Decoder) throws {}
    }

    public struct Model: Codable {
        public init(from decoder: Decoder) throws {}
    }

    struct Model: Codable {
        init(from decoder: Decoder) throws {}
    }
    ```

#### 填充`func encode(to encoder: Encoder)`

```
@Codable
struct BasicModel {
    var defaultVal: String = "hello world"
    var defaultVal2: String = Bool.random() ? "hello world" : ""
    let strict: String
    let noStrict: String?
    let autoConvert: Int?

    @CodingKey("hello")
    var hi: String = "there"

    @CodingNestedKey("nested.hi")
    @CodingTransformer(StringPrefixTransform("HELLO -> "))
    var codingKeySupport: String

    @CodingNestedKey("nested.b")
    var nestedB: String

    var testGetter: String {
        nestedB
    }

    func encode(to encoder: Encoder) throws {
        let container = encoder.container(keyedBy: AnyCodingKey.self)
        try container.encode(value: self.defaultVal, keys: ["defaultVal"], nestedKeys: [])
        try container.encode(value: self.defaultVal2, keys: ["defaultVal2"], nestedKeys: [])
        try container.encode(value: self.strict, keys: ["strict"], nestedKeys: [])
        try container.encode(value: self.noStrict, keys: ["noStrict"], nestedKeys: [])
        try container.encode(value: self.autoConvert, keys: ["autoConvert"], nestedKeys: [])
        try container.encode(value: self.hi, keys: ["hello", "hi"], nestedKeys: [])
        let $s19CodableWrapperTests10BasicModel0A0fMm_16fMu0_ = StringPrefixTransform("HELLO -> ")
        if let value = $s19CodableWrapperTests10BasicModel0A0fMm_16fMu0_.transformToJSON(self.codingKeySupport) {
            try container.encode(value: value, keys: ["codingKeySupport"], nestedKeys: ["nested.hi"])
        }
        try container.encode(value: self.nestedB, keys: ["nestedB"], nestedKeys: ["nested.b"])
    }
}
```
基本流程与`init(from decoder: Decoder)`一致，原则上是有值才encode而不是encode进去一个`nil`，扩写代码如下：
```
func genEncodeFunction(config: GenConfig) throws -> DeclSyntax {
    let body = memberProperties.enumerated().map { idx, member in
        if let transformerExpr = member.transformerExpr {
            let transformerVar = context.makeUniqueName(String(idx))

            if member.isOptional {
                return """
                let \(transformerVar) = \(transformerExpr)
                if let \(member.name) = self.\(member.name), let value = \(transformerVar).transformToJSON(\(member.name)) {
                    try container.encode(value: value, keys: [\(member.codingKeys.joined(separator: ", "))], nestedKeys: [\(member.nestedKeys.joined(separator: ", "))])
                }
                """
            } else {
                return """
                let \(transformerVar) = \(transformerExpr)
                if let value = \(transformerVar).transformToJSON(self.\(member.name)) {
                    try container.encode(value: value, keys: [\(member.codingKeys.joined(separator: ", "))], nestedKeys: [\(member.nestedKeys.joined(separator: ", "))])
                }
                """
            }

        } else {
            return "try container.encode(value: self.\(member.name), keys: [\(member.codingKeys.joined(separator: ", "))], nestedKeys: [\(member.nestedKeys.joined(separator: ", "))])"
        }
    }
    .joined(separator: "\n")

    let encoder: DeclSyntax = """
    \(raw: attributesPrefix(option: [.open, .public]))func encode(to encoder: Encoder) throws {
        let container = encoder.container(keyedBy: AnyCodingKey.self)
        \(raw: body)
    }
    """

    return encoder
}
```

## `@CodingKey` `@CodingNestedKey` `@CodingTransformer`增加Diagnostics
这些宏是用作占位标记的，不需要实际扩展。但为了增加一些严谨性，比如在以下情况下希望增加错误提示：
```
@CodingKey("a")
struct StructWraning1 {}
```
实现也很简单，抛异常即可。
```
public struct CodingKey: MemberMacro {
    public static func expansion(of node: AttributeSyntax, providingMembersOf _: some DeclGroupSyntax, in context: some MacroExpansionContext) throws -> [DeclSyntax] {
        throw ASTError("`\(self.self)` only use for `Property`")
    }
}
```
![20230705111402](http://images.testfast.cn/20230705111402.png)

这里也就印证了 `@CodingKey` 为什么不用 `@attached(memberAttribute)`(Member Attribute Macro) 而使用 `@attached(member)`(Member Macro) 的原因。如果不声明使用`@attached(member)`，就不会执行`MemberMacro`协议的实现，在`MemberMacro`位置写上`@CodingKey("a")`也就不会报错。

## 实现`@CodableSubclass`，方便的`Codable Class子类`

先举例展示`Codable Class子类`的缺陷。编写一个简单的测试用例：
![20230705113137](http://images.testfast.cn/20230705113137.png)

是不是出乎意料，原因是编译器只给`ClassModel`添加了`init(from decoder: Decoder)`，`ClassSubmodel`则没有。要解决问题还需要手动实现子类的`Codable`协议，十分不便：
![20230705113820](http://images.testfast.cn/20230705113820.png)

`@CodableSubclass`就是解决这个问题，实现也很简单，在适时的位置super call，方法标记成`override`就可以了。

```
func genDecoderInitializer(config: GenConfig) throws -> DeclSyntax {
    ...
    let decoder: DeclSyntax = """
    \(raw: attributesPrefix(option: [.public, .required]))init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: AnyCodingKey.self)
        \(raw: body)\(raw: config.isOverride ? "\ntry super.init(from: decoder)" : "")
    }
    """
}

func genEncodeFunction(config: GenConfig) throws -> DeclSyntax {
    ...
    let encoder: DeclSyntax = """
    \(raw: attributesPrefix(option: [.open, .public]))\(raw: config.isOverride ? "override " : "")func encode(to encoder: Encoder) throws {
        \(raw: config.isOverride ? "try super.encode(to: encoder)\n" : "")let container = encoder.container(keyedBy: AnyCodingKey.self)
        \(raw: body)
    }
    """
}
```

## 总结
至此，我们已经完成了 `@Codable` `@CodingKey` `@CodingNestedKey` `@CodingTransformer` `@CodableSubclass` 宏的全部实现。目前Swift Macro还处于Beta阶段， [CodableWrapper Macro 版](https://github.com/winddpan/CodableWrapper/tree/swift5.9-macro) 也还处于初期版本，未来还会迭代。
如果你觉得还不错，请给我的项目点个star吧 [https://github.com/winddpan/CodableWrapper/tree/swift5.9-macro](https://github.com/winddpan/CodableWrapper/tree/swift5.9-macro)

-----
**文章目录**
* [一、设计目标和手动实现这些目标特性](https://juejin.cn/post/7251501945272270908)
* [二、Codable宏的开发和实现](https://juejin.cn/post/7252170693676499004)
