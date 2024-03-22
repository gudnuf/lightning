{
  description = "A flake for developing on CLN";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [];
        };
        py3 = pkgs.python3.withPackages (p: [ p.mako ]);

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

        src = ./.;

        nativeBuildInputs = with pkgs; [
          pkg-config
          autoconf
          automake
          autogen
          libtool
          gettext
          lowdown
          protobuf
          py3
          unzip
          which
        ];

        deps = with pkgs; [
            gmp
            libsodium
            sqlite
            zlib
            poetry
        ];

        poetryDeps = with pkgs.python3Packages; [
          poetry-core
          mako
          grpcio-tools
        ];

        pluginDeps = with pkgs; [
          pyln_client
          pyln_proto
          pyln_bolt7
          bech32ref

        (python311.withPackages (ps: with ps; [
          flask-restx
          flask-cors
          flask-socketio
          gevent
          flask
          gunicorn
          cryptography
          coincurve
          json5
          base58
          bitstring
           pysocks
          ]))
        ];
      in
      {
        devShell = pkgs.mkShell {
          nativeBuildInputs = nativeBuildInputs;
          buildInputs = deps ++ pluginDeps;
          src = src;
          shellHook = ''
            # patchShebangs \
            #   tools/generate-wire.py \
            #   tools/update-mocks.sh \
            #   tools/mockup.sh \
            #   devtools/sql-rewrite.py \
            #   plugins/clnrest/clnrest.py \
            #   contrib/startup_regtest.sh
            # NIX_CFLAGS_COMPILE="$(pkg-config --cflags gtk+-3.0) $NIX_CFLAGS_COMPILE"
            # poetry install
            # poetry run ./configure --disable-rust
            # poetry run make -j$(nproc)
            # poetry run make -j$(nproc) check VALGRIND=0
            alias pythoncheck="PYTHONPATH=$(pwd)/contrib/pyln-proto:$(pwd)/contrib/pyln-client:$(pwd)/contrib/pyln-testing:$(pwd)/contrib/pylightning poetry run py.test tests/"
          '';
        };
      }
    );
}

# {
#   description = "A Bitcoin Lightning Network implementation in C";

#   inputs = {
#     nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
#     flake-utils.url = "github:numtide/flake-utils";
#   };

#   outputs = { self, nixpkgs, flake-utils, ... }:
#     flake-utils.lib.eachDefaultSystem (system:
#       let
#         pkgs = import nixpkgs {
#           inherit system;
#           overlays = [];
#         };
#         py3 = pkgs.python3.withPackages (p: [ p.mako ]);
#         clightning = pkgs.stdenv.mkDerivation rec {
#           pname = "clightning";
#           version = "24.02";
#           src = ./.;

#           nativeBuildInputs = [
#             pkgs.autoconf pkgs.autogen pkgs.automake pkgs.gettext pkgs.libtool
#             pkgs.lowdown pkgs.protobuf py3 pkgs.unzip pkgs.which
#           ] ++ pkgs.lib.optionals pkgs.stdenv.isDarwin [
#             pkgs.darwin.cctools pkgs.darwin.autoSignDarwinBinariesHook
#           ];

#           buildInputs = [
#             pkgs.gmp pkgs.libsodium pkgs.sqlite pkgs.zlib
#           ];

#           postPatch = if !pkgs.stdenv.isDarwin then ''
#             patchShebangs \
#               tools/generate-wire.py \
#               tools/update-mocks.sh \
#               tools/mockup.sh \
#               devtools/sql-rewrite.py \
#               plugins/clnrest/clnrest.py
#           '' else ''
#             substituteInPlace external/libwally-core/tools/autogen.sh --replace gsed sed && \
#             substituteInPlace external/libwally-core/configure.ac --replace gsed sed
#           '';

#           buildPhase = ''
#             poetry install
#             ./configure
#             make
#             sudo make install
#           '';

#           configureFlags = [];
#           makeFlags = [ "VERSION=v${version}" ];
#           enableParallelBuilding = true;

#           meta = with pkgs.lib; {
#             description = "A Bitcoin Lightning Network implementation in C";
#             longDescription = ''
#               c-lightning is a standard compliant implementation of the Lightning
#               Network protocol. The Lightning Network is a scalability solution for
#               Bitcoin, enabling secure and instant transfer of funds between any two
#               parties for any amount.
#             '';
#             homepage = "https://github.com/ElementsProject/lightning";
#             maintainers = with maintainers; [ jb55 prusnak ];
#             license = licenses.mit;
#             platforms = platforms.linux ++ platforms.darwin;
#           };
#         };
#       in
#       {
#         packages.default = clightning;
#       }
#     );
# }


# { lib
# , stdenv
# , darwin
# , fetchurl
# , autoconf
# , autogen
# , automake
# , gettext
# , libtool
# , lowdown
# , protobuf
# , unzip
# , which
# , gmp
# , libsodium
# , python3
# , sqlite
# , zlib
# }:
# let
#   py3 = python3.withPackages (p: [ p.mako ]);
# in
# stdenv.mkDerivation rec {
#   pname = "clightning";
#   version = "24.02";

#   src = ./.; # use the current directory as the source

#   # when building on darwin we need dawin.cctools to provide the correct libtool
#   # as libwally-core detects the host as darwin and tries to add the -static
#   # option to libtool, also we have to add the modified gsed package.
#   nativeBuildInputs = [ autoconf autogen automake gettext libtool lowdown protobuf py3 unzip which ]
#     ++ lib.optionals stdenv.isDarwin [ darwin.cctools darwin.autoSignDarwinBinariesHook ];

#   buildInputs = [ gmp libsodium sqlite zlib ];

#   # this causes some python trouble on a darwin host so we skip this step.
#   # also we have to tell libwally-core to use sed instead of gsed.
#   postPatch = if !stdenv.isDarwin then ''
#     patchShebangs \
#       tools/generate-wire.py \
#       tools/update-mocks.sh \
#       tools/mockup.sh \
#       devtools/sql-rewrite.py \
#       plugins/clnrest/clnrest.py
#   '' else ''
#     substituteInPlace external/libwally-core/tools/autogen.sh --replace gsed sed && \
#     substituteInPlace external/libwally-core/configure.ac --replace gsed sed
#   '';

#   configureFlags = [];

#   makeFlags = [ "VERSION=v${version}" ];

#   enableParallelBuilding = true;

#   meta = with lib; {
#     description = "A Bitcoin Lightning Network implementation in C";
#     longDescription = ''
#       c-lightning is a standard compliant implementation of the Lightning
#       Network protocol. The Lightning Network is a scalability solution for
#       Bitcoin, enabling secure and instant transfer of funds between any two
#       parties for any amount.
#     '';
#     homepage = "https://github.com/ElementsProject/lightning";
#     maintainers = with maintainers; [ jb55 prusnak ];
#     license = licenses.mit;
#     platforms = platforms.linux ++ platforms.darwin;
#   };
# }