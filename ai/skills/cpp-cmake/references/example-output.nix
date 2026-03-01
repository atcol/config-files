{
  description = "my-renderer — C++ development environment";

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
        name = "my-renderer-dev";

        # --- Packages available in your shell ---
        # Everything listed here will be on your PATH when you run
        # `nix develop`. Think of it as a project-local package manager.
        packages = with pkgs; [
          # -- Build system --
          cmake
          ninja           # Faster than make. Use: cmake -G Ninja ..
          pkg-config      # Helps CMake find libraries

          # -- Compiler --
          gcc             # GCC compiler (includes g++)

          # -- C++ Libraries --
          boost           # General-purpose C++ libraries
          eigen           # Linear algebra, matrices, vectors

          # -- Dev tools --
          clang-tools     # clang-format, clang-tidy, and more
          cmake-format    # Format CMakeLists.txt files
          gdb             # Debugger
        ];

        # --- Environment variables ---
        # These are set when you enter the shell. mkShell automatically
        # sets CMAKE_PREFIX_PATH so CMake can find all the Nix packages.
        shellHook = ''
          echo "🔧 my-renderer dev environment loaded"
          echo "   Compiler: $(g++ --version | head -1)"
          echo "   CMake:    $(cmake --version | head -1)"
          echo ""
          echo "   Quick start:"
          echo "     cmake -B build -G Ninja"
          echo "     cmake --build build"
          echo ""
          echo "   Format code:  clang-format -i src/**/*.cpp src/**/*.hpp"
          echo "   Lint code:    run-clang-tidy (after cmake build)"
        '';
      };

      # ---------------------------------------------------------------
      # Checks — run with: nix flake check
      # ---------------------------------------------------------------
      # These run automatically in CI. They verify your code is
      # formatted correctly.
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
    };
}
