{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    gcc
    gnumake
    pkg-config
    boost
    openssl
    db48
    wxwidgets_3_2
    glib
    gtk3
    qt5.qtbase
    qt5.qmake
    qt5.qttools
    qt5.qtwayland
    cmake
    ninja
    libevent
    python3
  ];

  shellHook = ''
    echo "=== Bitcoin v0.01 Linux Build Environment ==="
    echo "GCC: $(g++ --version | head -n 1)"
    echo "OpenSSL: $(openssl version)"
    echo "Berkeley DB: 4.8"
    export QT_PLUGIN_PATH="${pkgs.qt5.qtbase.bin}/${pkgs.qt5.qtbase.qtPluginPrefix}:${pkgs.qt5.qtwayland.bin}/${pkgs.qt5.qtbase.qtPluginPrefix}"
    export QT_QPA_PLATFORM_PLUGIN_PATH="${pkgs.qt5.qtbase.bin}/${pkgs.qt5.qtbase.qtPluginPrefix}/platforms:${pkgs.qt5.qtwayland.bin}/${pkgs.qt5.qtbase.qtPluginPrefix}/platforms"
  '';
}
