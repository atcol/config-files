---
name: nix-cpp-flake
description: >
  Generate Nix flakes for modern C++ projects using CMake. Creates a devShell with
  the full C++ toolchain (compiler, CMake, ninja, pkg-config), common libraries
  (Boost, Eigen, fmt, spdlog, etc.), and optional clang-format/clang-tidy checks.
  Use this skill whenever the user wants to: set up a Nix dev environment for C++,
  create a flake.nix for a CMake project, replace vcpkg/Conan with Nix, add
  C++ linting or formatting to a Nix flake, or asks about nix + cmake + C++ in any
  combination. Also trigger when the user mentions "nix develop" for C++, "nix flake
  init" for C++, reproducible C++ builds, or wants to add libraries like Boost or
  Eigen to a Nix shell. Even casual mentions like "I want to use nix for my C++
  project" or "how do I get boost working in nix" should trigger this skill.
---

# Nix Flake Generator for Modern C++ (CMake)

## What this skill does

Generates a complete, well-commented `flake.nix` (and supporting files) for C++
projects that use CMake. The output is tailored for C++ developers who are new to
Nix — every section is annotated so the user can learn as they go.

## When to use this skill

- User wants a Nix dev environment for a C++ project
- User wants to replace vcpkg, Conan, or system package managers with Nix
- User asks for a `flake.nix` that includes C++ libraries
- User wants clang-format or clang-tidy integrated into their Nix workflow
- User mentions CMake + Nix in any context

## Step 1: Gather project info

Before generating anything, figure out what the user needs. Ask about (if not
already clear from context):

1. **Project name** — used in the flake description and shell prompt
2. **C++ standard** — default to C++20 if not specified
3. **Libraries needed** — check `references/nixpkgs-cpp-libs.md` for the correct
   nixpkgs attribute names. Common ones: boost, eigen, fmt, spdlog, nlohmann_json,
   abseil-cpp, protobuf, grpc, opencv, catch2, gtest
4. **Compiler preference** — GCC (default) or Clang
5. **Extras** — clang-format, clang-tidy, doxygen, valgrind, gdb, ccache

If the user is unsure, use sensible defaults: C++20, GCC, with clang-format and
clang-tidy included.

## Step 2: Generate the flake

The generated `flake.nix` must follow this structure. Read each section carefully —
the comments are part of the output and should be included verbatim (they teach the
user how Nix works).

### Template structure

```nix
{
  description = "{{PROJECT_NAME}} — C++ development environment";

  # --- What are inputs? ---
  # Inputs are the dependencies of your flake. nixpkgs is the main one —
  # it's a giant collection of packages (including C++ libraries).
  # "Pinning" to a specific commit means everyone on your team gets
  # identical packages. No more "works on my machine."
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  # --- What are outputs? ---
  # Outputs define what your flake provides. Here we define a "devShell" —
  # a reproducible development environment you enter with `nix develop`.
  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in
    {
      # ---------------------------------------------------------------
      # Development shell — enter with: nix develop
      # ---------------------------------------------------------------
      devShells.${system}.default = pkgs.mkShell {
        name = "{{PROJECT_NAME}}-dev";

        # --- Packages available in your shell ---
        # Everything listed here will be on your PATH when you run
        # `nix develop`. Think of it as a project-local package manager.
        packages = with pkgs; [
          # -- Build system --
          cmake
          ninja          # Faster than make. Use: cmake -G Ninja ..
          pkg-config     # Helps CMake find libraries

          # -- Compiler --
          {{COMPILER_PACKAGES}}

          # -- C++ Libraries --
          {{LIBRARY_PACKAGES}}

          # -- Dev tools --
          {{DEV_TOOL_PACKAGES}}
        ];

        # --- Environment variables ---
        # These are set when you enter the shell. CMAKE_PREFIX_PATH
        # tells CMake where Nix put all the libraries.
        shellHook = ''
          echo "🔧 {{PROJECT_NAME}} dev environment loaded"
          echo "   Compiler: {{COMPILER_INFO}}"
          echo "   CMake:    $(cmake --version | head -1)"
          echo ""
          echo "   Quick start:"
          echo "     cmake -B build -G Ninja"
          echo "     cmake --build build"
          {{FORMAT_HOOK}}
        '';
      };

      {{CHECKS_SECTION}}
    };
}
```

### Filling in the template

**COMPILER_PACKAGES** — Based on user preference:
- GCC (default): `gcc` (this provides both gcc and g++)
- Clang: `clang` and `llvmPackages.libcxxClang` for libc++ if requested
- Both: include both; add a comment explaining how to switch via
  `CMAKE_CXX_COMPILER`

**LIBRARY_PACKAGES** — Look up the correct attribute name in
`references/nixpkgs-cpp-libs.md`. Each library should have a short comment
explaining what it is.

Example:
```nix
          boost           # General-purpose C++ libraries
          eigen           # Linear algebra, matrices, vectors
          fmt             # Modern string formatting (std::format backport)
```

**DEV_TOOL_PACKAGES** — Always include:
```nix
          cmake-format    # Format CMakeLists.txt files
          gdb             # Debugger
```

If clang-format/clang-tidy requested (common):
```nix
          clang-tools     # clang-format, clang-tidy, and more
```

Other optional tools based on user needs:
```nix
          valgrind        # Memory error detector
          ccache          # Compiler cache (speeds up rebuilds)
          doxygen         # Documentation generator
          cppcheck        # Static analysis
```

**FORMAT_HOOK** — If clang-format is included:
```nix
          echo "   Format code:  clang-format -i src/**/*.cpp src/**/*.hpp"
          echo "   Lint code:    run-clang-tidy (after cmake build)"
```

**CHECKS_SECTION** — If the user wants clang-format/clang-tidy checks:
```nix
      # ---------------------------------------------------------------
      # Checks — run with: nix flake check
      # ---------------------------------------------------------------
      # These run automatically in CI. They verify your code is
      # formatted and passes static analysis.
      checks.${system} = {
        format = pkgs.runCommand "check-format" {
          nativeBuildInputs = [ pkgs.clang-tools pkgs.fd ];
        } ''
          cd ${self}
          # Find all C++ files and check formatting
          fd -e cpp -e hpp -e h -e cc -e cxx . \
            --exec clang-format --dry-run --Werror {} \;
          touch $out
        '';
      };
```

## Step 3: Generate supporting files

Alongside the `flake.nix`, generate these files if relevant:

### `.clang-format` (if clang-format is in the shell)

```yaml
---
# .clang-format — auto-generated, customize to taste
# Docs: https://clang.llvm.org/docs/ClangFormatStyleOptions.html
BasedOnStyle: Google
Standard: c++20
ColumnLimit: 100
IndentWidth: 4
UseTab: Never
BreakBeforeBraces: Attach
AllowShortFunctionsOnASingleLine: Inline
SortIncludes: CaseSensitive
IncludeBlocks: Regroup
```

Adjust `Standard` to match the user's chosen C++ version.

### `.clang-tidy` (if clang-tidy is in the shell)

```yaml
---
# .clang-tidy — auto-generated, customize to taste
# Docs: https://clang.llvm.org/extra/clang-tidy/
Checks: >
  -*,
  bugprone-*,
  clang-analyzer-*,
  cppcoreguidelines-*,
  misc-*,
  modernize-*,
  performance-*,
  readability-*,
  -modernize-use-trailing-return-type,
  -readability-identifier-length
WarningsAsErrors: ''
HeaderFilterRegex: '.*'
```

### `.envrc` (always generate)

```bash
use flake
```

### `.gitignore` additions

Append to `.gitignore` (create if needed):
```
.direnv
```

### `CMakePresets.json` (helpful for new users)

```json
{
  "version": 6,
  "configurePresets": [
    {
      "name": "default",
      "displayName": "Default (Ninja)",
      "generator": "Ninja",
      "binaryDir": "${sourceDir}/build",
      "cacheVariables": {
        "CMAKE_CXX_STANDARD": "{{CXX_STANDARD}}",
        "CMAKE_CXX_STANDARD_REQUIRED": "ON",
        "CMAKE_EXPORT_COMPILE_COMMANDS": "ON"
      }
    },
    {
      "name": "debug",
      "inherits": "default",
      "displayName": "Debug",
      "cacheVariables": {
        "CMAKE_BUILD_TYPE": "Debug"
      }
    },
    {
      "name": "release",
      "inherits": "default",
      "displayName": "Release",
      "cacheVariables": {
        "CMAKE_BUILD_TYPE": "Release"
      }
    }
  ],
  "buildPresets": [
    { "name": "default", "configurePreset": "default" },
    { "name": "debug", "configurePreset": "debug" },
    { "name": "release", "configurePreset": "release" }
  ]
}
```

## Step 4: Explain what to do next

After generating files, always include a brief "getting started" section:

```
## Getting started

1. Make sure you have Nix installed with flakes enabled.
   If not: https://nixos.org/download + add to ~/.config/nix/nix.conf:
     experimental-features = nix-command flakes

2. Activate the dev shell:
     direnv allow
   Or enter manually:
     nix develop

3. Build your project:
     cmake --preset default
     cmake --build build
```

## Important notes

- **Always pin nixpkgs** — use `nixpkgs-unstable` for latest packages or a
  specific release like `nixos-24.11` for stability. Explain the trade-off.
- **Never use `nix-shell`** in the generated output — this skill targets the
  modern flakes workflow (`nix develop`), not legacy `nix-shell`.
- **`CMAKE_EXPORT_COMPILE_COMMANDS`** should always be ON — clang-tidy and most
  IDE integrations need `compile_commands.json`.
- **pkg-config** — always include it. Many CMake `find_package()` calls fall
  back to pkg-config, and without it you get mysterious "package not found" errors.
- If a library isn't in `references/nixpkgs-cpp-libs.md`, search nixpkgs
  (`nix search nixpkgs <name>`) and verify the attribute name before using it.
  Tell the user if you're uncertain.
- Keep the flake simple — x86_64-linux only unless the user asks for more.
  Avoid flake-utils unless multi-system is needed (it adds complexity for
  beginners).
