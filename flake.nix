{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
  };
  outputs = { self, nixpkgs, flake-utils, rust-overlay, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ rust-overlay.overlays.default ];
          config = {
            android_sdk.accept_license = true;
            allowUnfree = true;
          };
        };
        metadata = (builtins.fromTOML (builtins.readFile ./Cargo.toml)).package.metadata.android;
        toolchain = pkgs.rust-bin.stable.latest.default.override {
          targets = metadata.build_targets;
        };
        androidenv = pkgs.androidenv.composeAndroidPackages {
          toolsVersion = "26.1.1";
          platformToolsVersion = "33.0.2";
          buildToolsVersions = [ "33.0.0" ];
          includeNDK = true;
          includeEmulator = false;
          platformVersions = [ (toString metadata.sdk.target_sdk_version) ];
        };
      in
      with pkgs; {
        devShell = mkShell {
          nativeBuildInputs = [ toolchain jre ];
          ANDROID_HOME = "${androidenv.androidsdk}/libexec/android-sdk";
          ANDROID_NDK_ROOT = "${androidenv.androidsdk}/libexec/android-sdk/ndk-bundle";
        };
      });
}
