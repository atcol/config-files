{ lib, stdenvNoCC, fetchFromGitHub, fetchurl, python3, nodejs }:
let
  # Read the flake pin here as well: CI imports home.nix without flake inputs.
  locked = (builtins.fromJSON (builtins.readFile ../../flake.lock)).nodes.impeccable.locked;
  source = fetchFromGitHub {
    inherit (locked) owner repo rev;
    hash = locked.narHash;
  };
  engineVersion = "0.1.18";
  platforms = {
    x86_64-linux = { name = "linux-x64"; hash = "736ed785e74ae2344d3036127f614ddde5ab520a527d8bc82a891612ef71f648"; };
    aarch64-linux = { name = "linux-arm64"; hash = "317cb18d64b0f7715681dd6e574ad64b2adb5a6caf8e7a1b3b57965f805404be"; };
    x86_64-darwin = { name = "darwin-x64"; hash = "1f1eee78c142f7e40e16f481aeeeb1fad1d8515d8a1ef033d7c6d133e52232b3"; };
    aarch64-darwin = { name = "darwin-arm64"; hash = "543ee2f72036ad185dc9991ac3ba86b74d91f988f3d497776a088b8b65c8a9e1"; };
  };
  platform = platforms.${stdenvNoCC.hostPlatform.system};
  engine = fetchurl {
    url = "https://github.com/pbakaus/impeccable/releases/download/engine-v${engineVersion}/impeccable-${platform.name}";
    sha256 = platform.hash;
  };
in
stdenvNoCC.mkDerivation {
  pname = "impeccable";
  version = "4.8.0";
  src = source;
  nativeBuildInputs = [ python3 nodejs ];
  dontBuild = true;
  # Release engines are self-contained; do not strip or rewrite signed binaries.
  dontStrip = true;
  dontPatchELF = true;
  installPhase = ''
    runHook preInstall
    test "$(cat ENGINE_VERSION)" = ${engineVersion}
    test "$(python -c 'import json; print(json.load(open(".claude-plugin/plugin.json"))["version"])')" = "$version"
    install -Dm755 ${engine} "$out/libexec/impeccable"
    python ${./prepare.py} "$PWD" "$out" ${stdenvNoCC.shell}
    node --input-type=module - "$out" <<'JS'
    import fs from 'node:fs';
    import { hooksJsonFor } from './scripts/lib/transformers/hooks.js';
    const out = process.argv[2];
    for (const provider of ['claude', 'codex', 'gemini']) {
      const hooks = hooksJsonFor(provider, { configDir: '.agents' }).hooks;
      fs.writeFileSync(out + '/share/impeccable/' + provider + '/hooks.json', JSON.stringify(hooks));
    }
    JS
    runHook postInstall
  '';
  meta = {
    description = "Impeccable design skills and pinned engine";
    homepage = "https://github.com/pbakaus/impeccable";
    license = lib.licenses.asl20;
    platforms = builtins.attrNames platforms;
    mainProgram = "impeccable";
  };
}
