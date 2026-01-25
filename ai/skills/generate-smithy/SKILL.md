---
name: smithy
description: Create and edit Smithy IDL models for defining service APIs. Use when Claude needs to write Smithy code (.smithy files) for service definitions, operations, resources, data structures, or API modeling. Also use when converting APIs from URLs (OpenAPI, Swagger, GraphQL, HTML docs, JSON Schema, Protobuf) to Smithy. Triggers include requests for API definitions, service models, interface definitions, AWS-style APIs, API conversions, or any mention of Smithy IDL.
---

# Smithy IDL Skill

Smithy is a protocol-agnostic interface definition language (IDL) created by AWS for defining service APIs. It supports generating clients, servers, and documentation from a single model.

## File Structure

Every Smithy file has three ordered sections:

```smithy
$version: "2"                    // 1. Control section (required)

metadata key = "value"           // 2. Metadata section (optional)

namespace example.service        // 3. Shape section (required before shapes)

// Shapes and traits defined here
```

## Core Syntax Rules

- Files MUST be UTF-8 encoded
- Use `$version: "2"` for Smithy 2.0 (current version)
- Commas are optional whitespace (omit them in 2.0)
- Comments: `//` for line comments, `///` for documentation
- Namespace required before any shapes: `namespace com.example`

## Shape Types

### Simple Types
```smithy
string MyString
integer MyInt
boolean MyBool
blob MyBlob
timestamp MyTimestamp
```

### Enums
```smithy
enum Status {
    PENDING = "pending"
    ACTIVE = "active"
    INACTIVE = "inactive"
}

intEnum Priority {
    LOW = 1
    MEDIUM = 2
    HIGH = 3
}
```

### Collections
```smithy
list StringList {
    member: String
}

map StringToIntMap {
    key: String
    value: Integer
}
```

### Structures
```smithy
structure User {
    @required
    id: String
    
    name: String
    
    /// Optional with default
    active: Boolean = true
}
```

### Unions (tagged unions/discriminated unions)
```smithy
union PaymentMethod {
    creditCard: CreditCard
    bankTransfer: BankTransfer
    cash: Unit
}
```

## Service Definition

```smithy
$version: "2"
namespace example.shop

/// E-commerce service for managing products
@title("Shop API")
service ShopService {
    version: "2024-01-01"
    operations: [
        GetProduct
        ListProducts
        CreateProduct
    ]
    resources: [
        Product
    ]
}
```

## Operations

Define input and output as concrete structures:

```smithy
/// Get a product by ID
@readonly
@http(method: "GET", uri: "/products/{productId}")
operation GetProduct {
    input: GetProductInput
    output: GetProductOutput
    errors: [
        NotFoundError
        ValidationError
    ]
}

@input
structure GetProductInput {
    @required
    @httpLabel
    productId: String
}

@output
structure GetProductOutput {
    @required
    product: Product
}
```

Always use concrete structures for input/output rather than inline `:=` syntax. This improves:
- Reusability across operations
- Code generation quality
- Documentation clarity
- Type sharing between operations

## Resources

```smithy
resource Product {
    identifiers: {
        productId: String
    }
    properties: {
        name: String
        price: Integer
        description: String
    }
    read: GetProduct
    create: CreateProduct
    update: UpdateProduct
    delete: DeleteProduct
    list: ListProducts
}
```

## Common Traits

### Documentation
```smithy
/// Triple-slash for shape documentation
@documentation("Alternative documentation trait")
@externalDocumentation(url: "https://docs.example.com")
```

### Constraints
```smithy
@required                           // Member must be present
@length(min: 1, max: 100)          // String/list length
@range(min: 0, max: 1000)          // Numeric range
@pattern("^[a-z]+$")               // Regex pattern
@uniqueItems                        // List has unique items
```

### Nullability and Defaults
```smithy
structure Example {
    @required
    requiredField: String           // Never null
    
    optionalField: String           // Can be null/absent
    
    defaultField: String = "hello"  // Has default value
}
```

### HTTP Bindings
```smithy
@http(method: "POST", uri: "/users")
@httpLabel           // Path parameter
@httpQuery("name")   // Query parameter
@httpHeader("X-Id")  // Header
@httpPayload         // Request/response body
```

### Error Traits
```smithy
@error("client")     // 4xx error
@error("server")     // 5xx error
@httpError(404)      // Specific HTTP status
```

## Mixins

Reduce duplication by sharing members across structures:

```smithy
@mixin
structure TimestampMixin {
    createdAt: Timestamp
    updatedAt: Timestamp
}

structure User with [TimestampMixin] {
    @required
    id: String
    name: String
}
```

## Target Elision

Reference resource properties without explicit targets:

```smithy
resource User {
    identifiers: { userId: String }
    properties: { name: String, email: String }
}

structure GetUserOutput for User {
    $userId      // Automatically targets String from resource
    $name
    $email
}
```

## Converting APIs from URLs

When given a URL to convert to Smithy:

1. **Fetch the URL** using `web_fetch` to retrieve the content
2. **Identify the format**: OpenAPI/Swagger, GraphQL, HTML docs, JSON Schema, etc.
3. **Extract**: Types, endpoints, parameters, responses, errors
4. **Convert to Smithy** following patterns in [references/conversions.md](references/conversions.md)

### Quick Conversion Steps

```
URL → Fetch → Parse → Extract types/operations → Generate Smithy
```

**For OpenAPI/Swagger:**
- paths → operations with @http traits
- schemas/definitions → structures
- parameters → input members with @httpLabel/@httpQuery/@httpHeader
- responses → output structures and errors

**For HTML API docs:**
- Identify endpoint tables/lists
- Extract request/response examples
- Infer types from examples

**For GraphQL:**
- types → structures
- queries → @readonly operations  
- mutations → operations
- enums → enum shapes

Always generate complete, valid Smithy 2.0 with proper namespace, version, and service definition.

## Best Practices

1. **Always specify version**: Start files with `$version: "2"`
2. **Use documentation comments**: `///` before shapes
3. **Use concrete input/output structures**: Define separate structures with `@input`/`@output` traits
4. **Apply constraints**: Use `@required`, `@length`, `@range` appropriately
5. **Group related shapes**: Keep services, operations, and their structures together
6. **Use resources for CRUD**: Model entities with lifecycle operations as resources
7. **Use mixins**: Share common fields like timestamps, pagination

## Reference Files

- **[references/conversions.md](references/conversions.md)**: Converting APIs from URLs (OpenAPI, GraphQL, HTML docs, etc.)
- **[references/shapes.md](references/shapes.md)**: Detailed shape type reference
- **[references/traits.md](references/traits.md)**: Complete trait reference with examples
- **[references/http-bindings.md](references/http-bindings.md)**: HTTP protocol patterns
- **[references/examples.md](references/examples.md)**: Complete service examples
