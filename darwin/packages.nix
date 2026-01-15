{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # yabai
    # skhd
    helix
    mkalias
    gnupg
    pinentry_mac
    fastfetch
    dust
    git
    # spicetify-cli
    ripgrep
    fritzing
    defaultbrowser
    fd
    nixfmt-rfc-style
    zoxide
    fzf
  ];
}
