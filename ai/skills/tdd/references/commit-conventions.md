# Commit Message Conventions

## Structure

Use conventional commits format:

```
<type>(<scope>): <subject>

<body>

<footer>
```

## Types

- `feat`: New feature
- `fix`: Bug fix
- `refactor`: Code restructuring without behaviour change
- `test`: Adding or updating tests
- `docs`: Documentation changes
- `chore`: Maintenance tasks
- `style`: Formatting, whitespace (no logic change)
- `perf`: Performance improvements

## Rules

1. **Subject line**: Concise summary in imperative mood
2. **Second line**: Always blank
3. **Body**: Wrap lines at 72 characters
4. **Language**: Use British English spelling and grammar
5. **Footer**: Omit "Claude" or "Co-authored-by" footers
6. **Issue links**: Include on the last line if working from an issue

## Examples

### Simple fix

```
fix(auth): correct token expiration check

The token was being validated against the wrong timestamp,
causing premature session expiry for users in certain timezones.

Closes #123
```

### Feature

```
feat(api): add rate limiting to public endpoints

Implement token bucket algorithm with configurable limits per
endpoint. Defaults to 100 requests per minute for unauthenticated
users and 1000 for authenticated users.

Closes #456
```

### Refactor

```
refactor(database): extract query builder into separate module

Move query construction logic out of the repository layer to
improve testability and reduce duplication across data access
methods.
```
