{ pkgs, ... }:
{
  home.packages = [
    (pkgs.writeShellScriptBin "typst-figure" ''
      set -eu

      svg_path="''${1:-}"
      if [ -z "$svg_path" ]; then
        echo "usage: typst-figure path/to/figure.svg" >&2
        exit 2
      fi

      case "$svg_path" in
        ~/*) svg_path="$HOME/''${svg_path#~/}" ;;
      esac

      if [ -d "$svg_path" ]; then
        echo "typst-figure: path is a directory: $svg_path" >&2
        exit 1
      fi

      mkdir -p "$(dirname "$svg_path")"

      create_template() {
        cat <<'EOF' > "$svg_path"
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<!-- Created with Inkscape -->
<svg
  width="160mm"
  height="80mm"
  viewBox="0 0 160 80"
  version="1.1"
  xmlns="http://www.w3.org/2000/svg"
  xmlns:svg="http://www.w3.org/2000/svg"
  xmlns:inkscape="http://www.inkscape.org/namespaces/inkscape"
  xmlns:sodipodi="http://sodipodi.sourceforge.net/DTD/sodipodi-0.dtd">
  <sodipodi:namedview
    pagecolor="#ffffff"
    bordercolor="#000000"
    borderopacity="0.25"
    inkscape:showpageshadow="2"
    inkscape:pageopacity="0.0"
    inkscape:pagecheckerboard="0"
    inkscape:deskcolor="#dddddd"
    inkscape:document-units="mm" />
  <defs />
  <g inkscape:label="Layer 1" inkscape:groupmode="layer" id="layer1" />
</svg>
EOF
      }

      open_inkscape() {
        if command -v inkscape >/dev/null 2>&1; then
          inkscape "$svg_path" >/dev/null 2>&1 &
          return 0
        fi

        if open -a "Inkscape" "$svg_path" >/dev/null 2>&1; then
          return 0
        fi

        echo "typst-figure: Inkscape not found (install the app or add inkscape to PATH)." >&2
        return 1
      }

      if [ ! -s "$svg_path" ]; then
        create_template
      fi

      open_inkscape
    '')
  ];
}
