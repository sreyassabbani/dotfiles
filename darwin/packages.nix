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
