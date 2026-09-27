{ pkgs ? import <nixpkgs> { config = { permittedInsecurePackages = [ "openssl-1.1.1w" ]; }; } }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    gcc
    gnumake
    autoconf
    automake
    libtool
    pkg-config
    boost
    openssl_1_1
    db48
    zlib
    hexdump
    protobuf
    qrencode
    qt5.qtbase
    qt5.qtsvg
    qt5.qttools
    qt5.qtwayland
  ];

  shellHook = ''
    echo "=== Bitcoin Core v0.10.4 Linux Build Environment ==="
    echo "GCC: $(g++ --version | head -n 1)"
    echo "Boost: 1.89"
    echo "OpenSSL: $(openssl version)"
    echo "Berkeley DB: 4.8"
    export BOOST_LIB_DIR="${pkgs.boost.out}/lib"
    export BOOST_INCLUDE_DIR="${pkgs.boost.dev}/include"
    export PATH="${pkgs.qt5.qttools.dev}/bin:$PATH"
    export QT_PLUGIN_PATH="${pkgs.qt5.qtbase.bin}/${pkgs.qt5.qtbase.qtPluginPrefix}:${pkgs.qt5.qtwayland.bin}/${pkgs.qt5.qtbase.qtPluginPrefix}"
    export QT_QPA_PLATFORM_PLUGIN_PATH="${pkgs.qt5.qtbase.bin}/${pkgs.qt5.qtbase.qtPluginPrefix}/platforms:${pkgs.qt5.qtwayland.bin}/${pkgs.qt5.qtbase.qtPluginPrefix}/platforms"
  '';
}
