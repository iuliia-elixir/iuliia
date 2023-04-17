{ pkgs ? (import <nixpkgs> {}), ...}:
with pkgs;
let otp = beam.packages.erlangR25; in
pkgs.mkShell {
  buildInputs = [otp.elixir_1_11 otp.elixir-ls];
  shellHook = ''
    mkdir -p .nix-hex .nix-mix

    HEX_HOME=$PWD/.nix-hex
    MIX_HOME=$PWD/.nix-mix
    MIX_PATH=${otp.hex}/lib/erlang/lib/hex/ebin
    PATH=$HEX_HOME/bin:$MIX_HOME/bin$\{PATH+:}$PATH

    export HEX_HOME MIX_HOME MIX_PATH PATH
  '';
}
