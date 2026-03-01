# Nixpkgs C++ Library Reference

Quick-lookup table for common C++ libraries and their correct nixpkgs attribute
names. Use this when filling in `LIBRARY_PACKAGES` in the flake template.

## How to read this table

| User says...         | nixpkgs attr     | CMake find_package() | Notes                          |
|----------------------|------------------|----------------------|--------------------------------|
| **General purpose**  |                  |                      |                                |
| Boost                | `boost`          | `find_package(Boost)`| Headers + compiled libs        |
| Abseil / absl        | `abseil-cpp`     | `find_package(absl)` | Google's C++ utility library   |
| **Formatting / Logging** |              |                      |                                |
| fmt                  | `fmt`            | `find_package(fmt)`  | Modern formatting              |
| spdlog               | `spdlog`         | `find_package(spdlog)`| Fast logging (uses fmt)       |
| **JSON**             |                  |                      |                                |
| nlohmann_json        | `nlohmann_json`  | `find_package(nlohmann_json)` | Header-only JSON    |
| simdjson             | `simdjson`       | `find_package(simdjson)` | Fast JSON parsing         |
| **Math / Linear Algebra** |             |                      |                                |
| Eigen                | `eigen`          | `find_package(Eigen3)`| Header-only linear algebra    |
| Armadillo            | `armadillo`      | `find_package(Armadillo)` | Linear algebra (LAPACK) |
| BLAS/LAPACK          | `openblas`       | `find_package(BLAS)` | Numerical linear algebra       |
| **Networking / HTTP**|                  |                      |                                |
| cURL                 | `curl`           | `find_package(CURL)` | HTTP client                    |
| cpr                  | `cpr`            | `find_package(cpr)`  | C++ wrapper around cURL        |
| gRPC                 | `grpc`           | `find_package(gRPC)` | Also needs `protobuf`          |
| Protobuf             | `protobuf`       | `find_package(Protobuf)` | Serialization             |
| ZeroMQ               | `zeromq`         | `find_package(ZeroMQ)`| Message queuing               |
| **Graphics / GUI**   |                  |                      |                                |
| SDL2                 | `SDL2`           | `find_package(SDL2)` | Cross-platform media           |
| SFML                 | `sfml`           | `find_package(SFML)` | Simple multimedia              |
| GLFW                 | `glfw`           | `find_package(glfw3)`| OpenGL windowing               |
| Dear ImGui           | `imgui`          | (usually vendored)   | Immediate-mode GUI             |
| Qt 6                 | `qt6.full`       | `find_package(Qt6)`  | Use `qt6.qtbase` for minimal   |
| **Image / Media**    |                  |                      |                                |
| OpenCV               | `opencv`         | `find_package(OpenCV)`| Computer vision               |
| stb                  | `stb`            | (header-only, manual)| Single-file image loading      |
| **Crypto / Security**|                  |                      |                                |
| OpenSSL              | `openssl`        | `find_package(OpenSSL)`| TLS and crypto               |
| libsodium            | `libsodium`      | `find_package(sodium)`| Modern crypto                 |
| **Testing**          |                  |                      |                                |
| Google Test          | `gtest`          | `find_package(GTest)`| Google's test framework        |
| Catch2               | `catch2`         | `find_package(Catch2)`| Header-only test framework    |
| doctest              | `doctest`        | `find_package(doctest)`| Lightweight test framework   |
| Google Benchmark     | `gbenchmark`     | `find_package(benchmark)` | Microbenchmarking        |
| **Compression**      |                  |                      |                                |
| zlib                 | `zlib`           | `find_package(ZLIB)` | Compression                    |
| zstd                 | `zstd`           | `find_package(zstd)` | Facebook's fast compression    |
| lz4                  | `lz4`            | `find_package(lz4)`  | Extremely fast compression     |
| **Database**         |                  |                      |                                |
| SQLite               | `sqlite`         | `find_package(SQLite3)` | Embedded database           |
| libpqxx              | `libpqxx`        | `find_package(libpqxx)`| PostgreSQL client            |
| **Concurrency**      |                  |                      |                                |
| TBB                  | `tbb`            | `find_package(TBB)`  | Intel threading blocks         |
| **Argument parsing** |                  |                      |                                |
| CLI11                | `cli11`          | `find_package(CLI11)`| Command-line parser            |

## Notes for the flake generator

- **Header-only libraries** (Eigen, nlohmann_json, Catch2, doctest, CLI11):
  still include them in `packages` — Nix needs to know where the headers are.
  CMake finds them via `CMAKE_PREFIX_PATH` which `mkShell` sets up automatically.

- **Boost components**: If the user only needs specific Boost libraries, the
  full `boost` package is still the right thing to include. Nix doesn't split
  Boost into components like vcpkg does. The user selects components in CMake:
  `find_package(Boost REQUIRED COMPONENTS filesystem system)`

- **Qt**: Use `qt6.qtbase` for minimal, `qt6.full` for everything. Qt also needs
  `qt6.wrapQtAppsHook` in `nativeBuildInputs` if building a package (not needed
  for devShell).

- **If a library isn't listed here**: Search with `nix search nixpkgs <name>`
  to find the correct attribute. Warn the user that you're not 100% sure of
  the attribute name and they should verify.
