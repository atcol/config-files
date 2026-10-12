{ lib, stdenvNoCC, fetchFromGitHub, fetchurl, python3, nodejs }:
let
  # Read the flake pin here as well: CI imports home.nix without flake inputs.
  locked = (builtins.fromJSON (builtins.readFile ../../flake.lock)).nodes.impeccable.locked;
  source = fetchFromGitHub {
    inherit (locked) owner repo rev;
    hash = locked.narHash;
  };
  engineVersion = "0.1.14";
  platforms = {
    x86_64-linux = { name = "linux-x64"; hash = "3d31ec1a664ac35c815ea1d7c10abad1155ce364d0f461157eb837a34368efb6"; };
    aarch64-linux = { name = "linux-arm64"; hash = "396263ee694780db942483fc80933a012ef08bf981f5f26b0da5e16b6208c948"; };
    x86_64-darwin = { name = "darwin-x64"; hash = "dfa4570309939f49615a441baa9c73f1c2d339bf07494517a6c6eb2eb28aa0f5"; };
    aarch64-darwin = { name = "darwin-arm64"; hash = "abbd69d540532b91e9599c41d3a6127dfbaabae5e24bafd74ff7e2fb18f4f87c"; };
  };
  platform = platforms.${stdenvNoCC.hostPlatform.system};
  engine = fetchurl {
    url = "https://github.com/pbakaus/impeccable/releases/download/engine-v${engineVersion}/impeccable-${platform.name}";
    sha256 = platform.hash;
  };
in
stdenvNoCC.mkDerivation {
  pname = "impeccable";
  version = "4.5.2";
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
