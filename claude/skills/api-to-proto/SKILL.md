---
name: api-to-proto
description: Convert API documentation to Protocol Buffer (.proto) definitions. Use when given a URL to API docs (OpenAPI, Swagger, HTML docs, JSON examples) and asked to generate protobuf message types for request/response payloads. Triggers include requests to create .proto files from APIs, convert API schemas to protobuf, or generate typed message definitions from documentation.
---

# API to Protocol Buffer Converter

Convert API documentation into well-structured .proto files with comprehensive documentation.

## Workflow

1. **Fetch** the API documentation URL using `web_fetch`
2. **Identify** the format (OpenAPI/Swagger, HTML docs, JSON examples, etc.)
3. **Extract** endpoints, request/response schemas, and field descriptions
4. **Generate** .proto file with messages, enums, and documentation comments

## Conversion Process

### Step 1: Fetch and Analyze

```
web_fetch(url) → Identify format → Extract structure
```

Look for:
- **OpenAPI/Swagger**: `paths`, `components/schemas`, `definitions`
- **HTML docs**: Endpoint tables, request/response examples, parameter lists
- **JSON examples**: Infer types from sample payloads

### Step 2: Map Types

| Source Type | Proto Type |
|-------------|------------|
| string, text | string |
| integer, int, int32 | int32 |
| long, int64 | int64 |
| number, float | float |
| double | double |
| boolean, bool | bool |
| array of T | repeated T |
| object with properties | message |
| map/dict string→T | map<string, T> |
| enum with values | enum |
| nullable/optional | optional field |
| binary, bytes, base64 | bytes |
| date, datetime, timestamp | google.protobuf.Timestamp (or string) |

### Step 3: Generate Proto

Structure the output as:

```protobuf
syntax = "proto3";
package <api_name>;

// Import well-known types if needed
import "google/protobuf/timestamp.proto";

// Enums first
enum Status {
    STATUS_UNSPECIFIED = 0;
    STATUS_ACTIVE = 1;
    STATUS_INACTIVE = 2;
}

// Shared/nested messages
message Address {
    string street = 1;
    string city = 2;
}

// Request messages (suffix: Request)
message GetUserRequest {
    string user_id = 1;
}

// Response messages (suffix: Response)
message GetUserResponse {
    User user = 1;
}
```

## Documentation Rules

- Add `///` doc comments above every message and field
- Include field constraints (required, max length, valid values)
- Note which fields map to query params, headers, or body
- Preserve example values in comments when available

Example:
```protobuf
/// User account information
message User {
    /// Unique identifier (UUID format)
    string id = 1;
    
    /// Display name (1-100 characters)
    string name = 2;
    
    /// Account creation timestamp
    google.protobuf.Timestamp created_at = 3;
    
    /// Current account status
    Status status = 4;
}
```

## Naming Conventions

| Element | Convention | Example |
|---------|------------|---------|
| Package | lowercase, dots | `com.example.api` |
| Message | PascalCase | `UserProfile` |
| Field | snake_case | `user_id` |
| Enum | SCREAMING_SNAKE | `STATUS_ACTIVE` |
| Enum type | PascalCase | `Status` |

## Field Number Assignment

- Assign sequentially starting at 1
- Group related fields together
- Reserve 1-15 for frequently used fields (1-byte encoding)
- Never reuse numbers if updating an existing proto

## Handling API Patterns

### REST Endpoints → Messages

```
GET  /users/{id}      → GetUserRequest, GetUserResponse
POST /users           → CreateUserRequest, CreateUserResponse  
PUT  /users/{id}      → UpdateUserRequest, UpdateUserResponse
DELETE /users/{id}    → DeleteUserRequest, DeleteUserResponse
GET  /users           → ListUsersRequest, ListUsersResponse
```

### Query Parameters

```protobuf
/// List users with filtering
message ListUsersRequest {
    /// Filter by status
    optional Status status = 1;
    
    /// Maximum results (default: 20, max: 100)
    optional int32 limit = 2;
    
    /// Pagination cursor
    optional string page_token = 3;
}
```

### Nested Objects

Flatten or nest based on reusability:

```protobuf
// Reusable - define separately
message Money {
    string currency = 1;
    int64 amount_cents = 2;
}

message Order {
    Money total = 1;
    Money tax = 2;
}

// One-off - nest inline
message Order {
    message LineItem {
        string product_id = 1;
        int32 quantity = 2;
    }
    repeated LineItem items = 1;
}
```

## Reference

See [references/protobuf-patterns.md](references/protobuf-patterns.md) for additional patterns including:
- Pagination responses
- Error handling
- Wrapper types
- OneOf for variants
- Well-known types
