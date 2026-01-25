# Protobuf Patterns Reference

## Pagination

```protobuf
message ListUsersRequest {
    /// Maximum items per page (default: 20, max: 100)
    optional int32 page_size = 1;
    
    /// Token from previous response for next page
    optional string page_token = 2;
}

message ListUsersResponse {
    repeated User users = 1;
    
    /// Token for next page, empty if no more results
    string next_page_token = 2;
    
    /// Total count (if API provides it)
    optional int32 total_count = 3;
}
```

## Error Responses

```protobuf
/// Standard API error
message Error {
    /// Machine-readable error code
    string code = 1;
    
    /// Human-readable message
    string message = 2;
    
    /// Additional error details
    repeated ErrorDetail details = 3;
}

message ErrorDetail {
    /// Field that caused the error
    string field = 1;
    
    /// Description of the issue
    string reason = 2;
}
```

## OneOf for Variants

Use when a field can be one of several types:

```protobuf
message PaymentMethod {
    oneof method {
        CreditCard credit_card = 1;
        BankAccount bank_account = 2;
        Crypto crypto = 3;
    }
}

message CreditCard {
    string last_four = 1;
    string brand = 2;
    int32 exp_month = 3;
    int32 exp_year = 4;
}
```

## Wrapper Types for Nullable Primitives

Proto3 doesn't distinguish between "not set" and "zero value". Use wrappers when null is meaningful:

```protobuf
import "google/protobuf/wrappers.proto";

message Settings {
    /// Null means "use default", 0 means "disabled"
    google.protobuf.Int32Value timeout_seconds = 1;
    
    /// Null means "inherit", false means "explicitly disabled"
    google.protobuf.BoolValue notifications_enabled = 2;
}
```

Or use `optional` keyword (proto3 syntax):

```protobuf
message Settings {
    optional int32 timeout_seconds = 1;
    optional bool notifications_enabled = 2;
}
```

## Well-Known Types

```protobuf
import "google/protobuf/timestamp.proto";
import "google/protobuf/duration.proto";
import "google/protobuf/struct.proto";
import "google/protobuf/any.proto";

message Event {
    /// When the event occurred
    google.protobuf.Timestamp occurred_at = 1;
    
    /// How long the event lasted
    google.protobuf.Duration duration = 2;
    
    /// Arbitrary JSON metadata
    google.protobuf.Struct metadata = 3;
    
    /// Polymorphic payload
    google.protobuf.Any payload = 4;
}
```

## Maps

```protobuf
message Config {
    /// String to string mapping
    map<string, string> labels = 1;
    
    /// String to message mapping
    map<string, FeatureFlag> features = 2;
}
```

## Enums with Prefix Convention

Always include UNSPECIFIED as 0, prefix values with enum name:

```protobuf
enum OrderStatus {
    ORDER_STATUS_UNSPECIFIED = 0;
    ORDER_STATUS_PENDING = 1;
    ORDER_STATUS_CONFIRMED = 2;
    ORDER_STATUS_SHIPPED = 3;
    ORDER_STATUS_DELIVERED = 4;
    ORDER_STATUS_CANCELLED = 5;
}
```

## Repeated vs Optional

```protobuf
message Example {
    // Empty list is valid, always present
    repeated string tags = 1;
    
    // Might not be set at all
    optional string nickname = 2;
    
    // Always present, defaults to "" if not set
    string name = 3;
}
```

## Reserved Fields

When deprecating fields, reserve the number:

```protobuf
message User {
    reserved 2, 5 to 7;
    reserved "old_email", "legacy_id";
    
    string id = 1;
    // field 2 was old_email
    string email = 3;
    string name = 4;
    // fields 5-7 were removed
}
```

## Nested Messages for Scoping

```protobuf
message Order {
    string id = 1;
    repeated Item items = 2;
    Summary summary = 3;
    
    /// Line item in an order
    message Item {
        string product_id = 1;
        int32 quantity = 2;
        int64 unit_price_cents = 3;
    }
    
    /// Order totals
    message Summary {
        int64 subtotal_cents = 1;
        int64 tax_cents = 2;
        int64 total_cents = 3;
    }
}
```

## API-Specific Patterns

### Kraken-style (form-encoded with signatures)

```protobuf
/// Common fields for all private requests
message PrivateRequestBase {
    /// Unique, incrementing nonce (milliseconds since epoch)
    string nonce = 1;
}

message GetBalanceRequest {
    string nonce = 1;
    /// Optional: "rebased" to include rebasing multiplier
    optional string rebase_multiplier = 2;
}

message GetBalanceResponse {
    /// Asset code → balance amount
    map<string, string> balances = 1;
}
```

### REST with Path/Query/Body Split

Document where each field goes:

```protobuf
message UpdateUserRequest {
    /// Path parameter: /users/{user_id}
    string user_id = 1;
    
    /// Query parameter: ?notify=true
    optional bool notify = 2;
    
    /// Body fields below
    optional string name = 3;
    optional string email = 4;
}
```
