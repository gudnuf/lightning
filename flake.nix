{
  description = "A flake for building Core Lightning";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
      pyln_bolt7 = pkgs.python3Packages.buildPythonPackage rec {
            pname = "pyln_bolt7";
            version = "cd894663";
            src = pkgs.fetchFromGitHub {
              owner = "niftynei";
              repo = "${pname}";
              rev = "${version}";
              sha256 = "sha256-//XG8aF2mW5DX0sBsAV1bL+9RLrvUXYpPSX9bz5f/OU=";
            };
            doCheck = false;
            propagatedBuildInputs = [];
        };
        bech32ref = pkgs.python3Packages.buildPythonPackage rec {
            pname = "bech32ref";
            version = "5f11b2e";
            src = pkgs.fetchFromGitHub {
              owner = "niftynei";
              repo = "${pname}";
              rev = "${version}";
              sha256 = "sha256-fvR6y2FpEE5sWLDOGLCOR180W15P5t+PmroHRNbWQbA=";
            };
            doCheck = false;
            propagatedBuildInputs = [];
        };
        pyln_proto = pkgs.python3Packages.buildPythonPackage rec {
            pname = "pyln_proto";
            version = "87643bed";
            src = pkgs.fetchFromGitHub {
              owner = "niftynei";
              repo = "${pname}";
              rev = "${version}";
              sha256 = "sha256-q8Qh39e23C0jyerRlfobArKwWB9Zj3ghFS479oxcep8=";
            };
            doCheck = false;
            propagatedBuildInputs = [];
        };
        pyln_client = pkgs.python3Packages.buildPythonPackage rec {
            pname = "pyln_client";
            version = "23.5.2";
            src = pkgs.fetchFromGitHub {
              inherit version;
              owner = "niftynei";
              repo = "${pname}";
              rev = "250b8a2";
              sha256 = "sha256-vhGyBA5C5bgi5nMHgs9hjIUGOOKTwV31/OeBnQJUaL0=";
            };
            doCheck = false;
            propagatedBuildInputs = [ pyln_proto pyln_bolt7];
        };
        pkgs = import nixpkgs {
          inherit system;
        };
      in {
        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [
            bitcoind
            poetry
            autoconf
            automake
            buildPackages.gcc
            git
            libtool
            sqlite
            python3
            nettools
            zlib
            libsodium
            gettext
            valgrind
            shellcheck
            cppcheck
            secp256k1
            jq
            lowdown
            cargo
            rustfmt
            protobuf
            pyln_client
            pyln_proto
            pyln_bolt7
            bech32ref

            (python311.withPackages (ps: with ps; [
              mako
              poetry-core
              grpcio-tools
              ipython
              pip
              base58
              bitstring
              pysocks
              cryptography
              coincurve
              flask
              flask-restx
              flask-cors
              flask-socketio
              gunicorn
              gevent
              gevent-websocket
              json5
            ]))
          ];
        };
      }
    );
}
