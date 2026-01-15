{ username, pkgs, ... }:
{
  home = {
    username = username;
    homeDirectory = "/Users/${username}";
    enableNixpkgsReleaseCheck = false;
    stateVersion = "25.05";
    sessionVariables = {
      EDITOR = "hx";
    };
    packages = [
      pkgs.simple-completion-language-server
    ];
  };

  programs.home-manager.enable = true;
}
