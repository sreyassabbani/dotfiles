{ username, ... }:
{
  home = {
    username = username;
    homeDirectory = "/Users/${username}";
    enableNixpkgsReleaseCheck = false;
    stateVersion = "25.05";
    sessionVariables = {
      EDITOR = "hx";
    };
  };

  programs.home-manager.enable = true;
}
