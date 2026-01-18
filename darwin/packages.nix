{ pkgs, ... }:

let
  lib = pkgs.lib;

  inkscape-textext-fixed = pkgs.symlinkJoin {
    name = "inkscape-textext-fixed";

    paths = [
      pkgs.inkscape
      pkgs.inkscape-extensions.textext
    ];

    nativeBuildInputs = [
      pkgs.makeWrapper
      pkgs.gdk-pixbuf.dev
    ];

    postBuild = ''
      set -euo pipefail

      mkdir -p "$out/lib"
      cache="$out/lib/gdk-pixbuf-loaders.cache"

      # Find the gdk-pixbuf module version dir (e.g. .../gdk-pixbuf-2.0/2.10.0)
      gp_dir=""
      for d in ${pkgs.gdk-pixbuf}/lib/gdk-pixbuf-2.0/*; do gp_dir="$d"; break; done

      rsvg_dir=""
      for d in ${pkgs.librsvg}/lib/gdk-pixbuf-2.0/*; do rsvg_dir="$d"; break; done

      shopt -s nullglob
      modules=(
        "$gp_dir/loaders"/*.{so,dylib}
        "$rsvg_dir/loaders"/*.{so,dylib}
      )

      gdk-pixbuf-query-loaders "''${modules[@]}" > "$cache"

      wrapProgram "$out/bin/inkscape" \
        --set INKSCAPE_DATADIR "$out/share" \
        --set GTK_THEME "Adwaita" \
        --prefix XDG_DATA_DIRS : "$out/share:${
          lib.makeSearchPath "share" [
            pkgs.gtk3
            pkgs.adwaita-icon-theme
            pkgs.hicolor-icon-theme
            pkgs.gsettings-desktop-schemas
          ]
        }" \
        --set GSETTINGS_SCHEMA_DIR "${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}" \
        --set GDK_PIXBUF_MODULE_FILE "$cache" \
        --prefix GI_TYPELIB_PATH : "${pkgs.gobject-introspection}/lib/girepository-1.0" \
        --prefix PATH : "${
          lib.makeBinPath [
            pkgs.python3
            pkgs.tectonic
            pkgs.pdf2svg
            pkgs.ghostscript
          ]
        }"
    '';
  };
in
{
  environment.systemPackages = with pkgs; [
    helix
    mkalias
    gnupg
    pinentry_mac
    fastfetch
    dust
    git
    ripgrep
    fritzing
    defaultbrowser
    fd
    nixfmt-rfc-style
    nixd
    zoxide
    fzf

    inkscape-textext-fixed
  ];
}
