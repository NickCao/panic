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
        toolchain = pkgs.rust-bin.stable.latest.default.override {
          targets = (builtins.fromTOML (builtins.readFile ./Cargo.toml)).package.metadata.android.build_targets;
        };
        androidenv = pkgs.androidenv.composeAndroidPackages {
          toolsVersion = "26.1.1";
          platformToolsVersion = "33.0.2";
          buildToolsVersions = [ "33.0.0" ];
          includeEmulator = false;
          includeNDK = true;
          emulatorVersion = "31.3.9";
          platformVersions = [ "30" ];
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
