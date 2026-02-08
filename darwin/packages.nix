{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # yabai
    # skhd
    helix
    typst
    mkalias
    gnupg
    pinentry_mac
    fastfetch
    dust
    git
    # spicetify-cli
    ripgrep
    just
    jq
    fritzing
    defaultbrowser
    fd
    nixfmt-rfc-style
    nixd
    zoxide
    fzf
  ];
}
