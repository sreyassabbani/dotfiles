{ config, ... }:
{
  nix-homebrew = {
    enable = true;
    enableRosetta = true;
    user = config.system.primaryUser;
    autoMigrate = true;
  };

  homebrew = {
    enable = true;

    brews = [
      "mas"
      "ffmpeg"
      "gh"
      "tldr"
      "tree"
    ];

    casks = [
      "firefox"
      "hammerspoon"
      "google-chrome"
      "notion"
      "obsidian"
      "codex"
      "microsoft-powerpoint"
      "microsoft-word"
      "zoom"
      "skim"
      "slack"
      "ghostty"
      "iina"
      "google-drive"
      "zotero"
      "spotify"
      "notion-calendar"
      "anki"
      "antigravity"
      "visual-studio-code"
      "chatgpt-atlas"
      "the-unarchiver"
      "zen-browser"
    ];

    masApps = { };

    onActivation.cleanup = "zap";
    onActivation.autoUpdate = true;
    onActivation.upgrade = true;
  };
}
