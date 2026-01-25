---
name: rust-nix-bootstrap
description: Bootstrap a new Rust project with Nix flake, or add Nix flake to an existing Rust project. Triggers on "create a new Rust project", "bootstrap a Rust CLI/app/library", "add flake.nix to existing Rust project", "set up Rust with Nix", or similar requests for Rust project scaffolding with Nix/flake support.
---

# Rust Nix Bootstrap

Bootstrap Rust projects with a complete Nix flake development environment.

## Workflow

### 1. Detect or Ask Project Type

Check if targeting an existing project (has `Cargo.toml`). If new project, ask:

- **CLI app**: Binary with argument parsing
- **Library**: Reusable crate
- **Workspace**: Multi-crate project

### 2. Gather Project Info

- Project name (use directory name if existing, otherwise ask)
- Brief description (for flake.nix and Cargo.toml)

### 3. Generate Files

Copy and customize templates from `assets/`:

| Template | Output | Notes |
|----------|--------|-------|
| `flake.nix.template` | `flake.nix` | Replace `{{PROJECT_NAME}}`, `{{PROJECT_DESCRIPTION}}` |
| `envrc.template` | `.envrc` | Copy as-is |
| `justfile.template` | `justfile` | Copy as-is |
| `ci.yml.template` | `.github/workflows/ci.yml` | Copy as-is |

### 4. Generate Cargo.toml (New Projects Only)

```toml
[package]
name = "{{PROJECT_NAME}}"
version = "0.1.0"
edition = "2024"
description = "{{PROJECT_DESCRIPTION}}"

[dependencies]
serde = { version = "1", features = ["derive"] }
tokio = { version = "1", features = ["full"] }
chrono = { version = "0.4", features = ["serde"] }
# Add for CLI only:
clap = { version = "4", features = ["derive"] }
```

### 5. Generate src/ (New Projects Only)

**CLI app** (`src/main.rs`):
```rust
use clap::Parser;

#[derive(Parser, Debug)]
#[command(author, version, about)]
struct Args {
    #[arg(short, long)]
    name: Option<String>,
}

#[tokio::main]
async fn main() {
    let args = Args::parse();
    println!("Hello, {}!", args.name.as_deref().unwrap_or("world"));
}
```

**Library** (`src/lib.rs`):
```rust
pub fn add(left: u64, right: u64) -> u64 {
    left + right
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn it_works() {
        assert_eq!(add(2, 2), 4);
    }
}
```

**Workspace** (`Cargo.toml` at root):
```toml
[workspace]
resolver = "2"
members = ["crates/*"]

[workspace.dependencies]
serde = { version = "1", features = ["derive"] }
tokio = { version = "1", features = ["full"] }
chrono = { version = "0.4", features = ["serde"] }
```

Then create `crates/{{PROJECT_NAME}}/` with its own `Cargo.toml` and `src/`.

### 6. Initialize Git and Nix

```bash
git init  # if not already a repo
echo ".direnv" >> .gitignore
cargo generate-lockfile  # needed for flake
```

### 7. Remind User

After generation, remind:
- Run `direnv allow` to activate the dev shell
- Or `nix develop` to enter manually
- `just` to see available commands
