{
  description = "A flake template for nix-darwin and Determinate Nix";

  ########################################
  # Flake Inputs
  ########################################
  inputs = {
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0";

    nix-darwin = {
      url = "https://flakehub.com/f/nix-darwin/nix-darwin/0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    determinate = {
      url = "https://flakehub.com/f/DeterminateSystems/determinate/3";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # spicetify-nix.url = "github:Gerg-L/spicetify-nix";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";

    home-manager = {
      url = "https://flakehub.com/f/nix-community/home-manager/0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
  };

  ########################################
  # Flake Outputs
  ########################################
  outputs =
    { self, ... }@inputs:
    let
      username = "sreysus";
      system = "aarch64-darwin";
      vscodeExtensionsOverlay = inputs.nix-vscode-extensions.overlays.default;
    in
    {
      ########################################
      # System Configuration (nix-darwin)
      ########################################
      darwinConfigurations."${username}-${system}" = inputs.nix-darwin.lib.darwinSystem {
        inherit system;

        modules = [
          ########################################
          # Determinate Nix
          ########################################
          inputs.determinate.darwinModules.default

          ########################################
          # nix-homebrew
          ########################################
          inputs.nix-homebrew.darwinModules.nix-homebrew
          {
            nix-homebrew = {
              enable = true;
              enableRosetta = true;
              user = username;
              autoMigrate = true;
            };
          }

          ########################################
          # Base nix-darwin Config
          ########################################
          self.darwinModules.base

          ########################################
          # Determinate Nix Config
          ########################################
          self.darwinModules.nixConfig

          ########################################
          # Inline nix-darwin module (empty)
          ########################################
          (
            { pkgs, ... }:
            {
              nixpkgs.overlays = [ vscodeExtensionsOverlay ];
            }
          )

          ########################################
          # Home Manager
          ########################################
          inputs.home-manager.darwinModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;

              users.${username} =
                { pkgs, ... }:
                {
                  imports = [
                    ./home/zsh.nix
                    ./home/helix.nix
                    ./home/git.nix
                  ];

                  home = {
                    username = username;
                    homeDirectory = "/Users/${username}";
                    enableNixpkgsReleaseCheck = false;
                    stateVersion = "25.05";
                    sessionVariables = {
                      EDITOR = "hx";
                    };
                  };

                  programs = {
                    direnv = {
                      enable = true;
                      enableZshIntegration = true; # see note on other shells below
                      nix-direnv.enable = true;
                    };

                    zsh.enable = true; # see note on other shells below

                    home-manager.enable = true;

                    ########################################
                    # VSCode Config
                    ########################################
                    vscode = {
                      enable = true;
                      profiles.default = {
                        userSettings = {
                          "editor.formatOnSave" = true;
                          "workbench.colorTheme" = "Gruvbox Dark Soft";
                          "workbench.iconTheme" = "icons";
                          "git.autofetch" = true;
                          "editor.fontFamily" = "JetBrains Mono";
                          "editor.fontLigatures" = true;

                        };

                        extensions = with pkgs.vscode-marketplace; [
                          openai.chatgpt
                          jnoortheen.nix-ide
                          jdinhlife.gruvbox
                          tal7aouy.icons
                          astro-build.astro-vscode
                          # not sure how to enable vscode extensions per project
                          esbenp.prettier-vscode
                          platformio.platformio-ide
                          rust-lang.rust-analyzer
                          ms-python.python
                        ];
                      };
                    };

                    ########################################
                    # SSH Config
                    ########################################
                    ssh = {
                      enable = true;
                      enableDefaultConfig = false;

                      matchBlocks."github.com" = {
                        hostname = "github.com";
                        user = "git";
                        identityFile = "~/.ssh/id_ed25519";

                        extraOptions = {
                          AddKeysToAgent = "yes";
                          UseKeychain = "yes";
                        };
                      };
                    };

                    ghostty = {
                      enable = true;

                      # Important: don't use pkgs.ghostty on macOS right now, it's broken.
                      package = null;

                      # Optional, but safe: avoids bat-syntax issues on mac
                      installBatSyntax = false;

                      settings = {
                        theme = "Gruvbox Dark";

                        window-padding-x = 30;
                        # window-padding-y = "40,0"; # if you want this later

                        font-size = 16;

                        keybind = [
                          "global:cmd+grave_accent=toggle_quick_terminal"
                          "shift+enter=text:\\n"
                        ];
                      };
                    };
                  };
                };
            };
          }
        ];
      };

      ########################################
      # nix-darwin Modules
      ########################################
      darwinModules = {
        base =
          { config, pkgs, ... }:
          {
            services.yabai = {
              enable = true;
              enableScriptingAddition = false;

              config = {
                layout = "bsp";
                auto_balance = "on";
                window_gap = 8;
                top_padding = 10;
                bottom_padding = 10;
                left_padding = 10;
                right_padding = 10;
              };

              extraConfig = ''
                yabai -m rule --add app="System Settings" manage=off
              '';
            };

            services.skhd = {
              enable = true;

              skhdConfig = ''
                # ---------- Focus (keep your existing muscle memory) ----------
                alt - h : yabai -m window --focus west
                alt - j : yabai -m window --focus south
                alt - k : yabai -m window --focus north
                alt - l : yabai -m window --focus east

                # ---------- Swap (reorder without changing the BSP structure) ----------
                alt + shift - h : yabai -m window --swap west
                alt + shift - j : yabai -m window --swap south
                alt + shift - k : yabai -m window --swap north
                alt + shift - l : yabai -m window --swap east

                # ---------- Warp (move window into that direction in the tree) ----------
                ctrl + alt - h : yabai -m window --warp west
                ctrl + alt - j : yabai -m window --warp south
                ctrl + alt - k : yabai -m window --warp north
                ctrl + alt - l : yabai -m window --warp east

                # ---------- Float / Zoom ----------
                alt - space : yabai -m window --toggle float
                alt - f     : yabai -m window --toggle zoom-fullscreen

                # ---------- Space layout hygiene ----------
                ctrl + alt - b : yabai -m space --balance
                ctrl + alt - r : yabai -m space --rotate 90
                ctrl + alt - m : yabai -m space --mirror x-axis

                # ---------- Resize (nudges; works for tiled and floating in different ways) ----------
                # Tiled windows: yabai interprets these as changing split ratios.
                # Floating windows: it resizes the actual frame.
                ctrl + alt + cmd - h : yabai -m window --resize left:-50:0
                ctrl + alt + cmd - j : yabai -m window --resize bottom:0:50
                ctrl + alt + cmd - k : yabai -m window --resize top:0:-50
                ctrl + alt + cmd - l : yabai -m window --resize right:50:0

                # ---------- Quality-of-life toggles ----------
                ctrl + alt - g : yabai -m space --toggle gap
                ctrl + alt - p : yabai -m space --toggle padding
              '';
            };

            system.stateVersion = 6;
            system.configurationRevision = self.rev or self.dirtyRev or null;
            system.primaryUser = username;
            system.activationScripts.defaultBrowser.text = ''
              # See available names:
              #   ${pkgs.defaultbrowser}/bin/defaultbrowser -l
              ${pkgs.defaultbrowser}/bin/defaultbrowser "Zen Browser"
            '';

            users.users.${username} = {
              name = username;
              home = "/Users/${username}";
            };

            ########################################
            # System Packages
            ########################################
            environment.systemPackages = with pkgs; [
              yabai
              skhd
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

            ########################################
            # Homebrew
            ########################################
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

            ########################################
            # Symlink Applications
            ########################################
            system.activationScripts.applications.text =
              let
                env = pkgs.buildEnv {
                  name = "system-applications";
                  paths = config.environment.systemPackages;
                  pathsToLink = [ "/Applications" ];
                };
              in
              pkgs.lib.mkForce ''
                echo "setting up /Applications..." >&2
                rm -rf /Applications/Nix\ Apps
                mkdir -p /Applications/Nix\ Apps

                find ${env}/Applications -maxdepth 1 -type l -exec readlink '{}' + |
                while read -r src; do
                  app_name=$(basename "$src")
                  echo "copying $src" >&2
                  ${pkgs.mkalias}/bin/mkalias "$src" "/Applications/Nix Apps/$app_name"
                done
              '';

            ########################################
            # macOS Defaults
            ########################################
            system.keyboard.enableKeyMapping = true;
            system.keyboard.remapCapsLockToEscape = true;

            system.defaults = {
              dock = {
                autohide = true;
                show-recents = false;
                tilesize = 25;
                largesize = 60;
                orientation = "bottom";

                persistent-apps = [
                  { app = "/Applications/Anki.app"; }
                  { app = "/Applications/Ghostty.app"; }
                  { app = "/Applications/ChatGPT Atlas.app"; }
                  { app = "/Applications/Zen.app"; }
                  { app = "/Applications/Obsidian.app"; }
                  { app = "/Applications/Notion Calendar.app"; }
                  { app = "/Applications/Zotero.app"; }
                ];

                persistent-others = [ ];
              };
            };

            ########################################
            # Fonts
            ########################################
            fonts.packages = with pkgs; [
              nerd-fonts.jetbrains-mono
              nerd-fonts.symbols-only
            ];
            nixpkgs.config.allowUnfree = true;
          };

        ########################################
        # Determinate Nix Config Module
        ########################################
        nixConfig =
          { ... }:
          {
            nix.enable = false;

            determinate-nix.customSettings = {
              eval-cores = 0;

              extra-experimental-features = [
                "build-time-fetch-tree"
                "parallel-eval"
              ];
            };
          };
      };

      ########################################
      # DevShell
      ########################################
      devShells.${system}.default =
        let
          pkgs = import inputs.nixpkgs { inherit system; };
        in
        pkgs.mkShellNoCC {
          packages = with pkgs; [
            (writeShellApplication {
              name = "apply-nix-darwin-configuration";
              runtimeInputs = [
                inputs.nix-darwin.packages.${system}.darwin-rebuild
              ];
              text = ''
                echo "> Applying nix-darwin configuration..."
                echo "> Running darwin-rebuild switch as root..."
                sudo darwin-rebuild switch --flake .#"${username}-${system}"
                echo "> darwin-rebuild switch was successful ✅"
                echo "> macOS config was successfully applied 🚀"
              '';
            })

            self.formatter.${system}
          ];
        };

      ########################################
      # Formatter
      ########################################
      formatter.${system} = inputs.nixpkgs.legacyPackages.${system}.nixfmt-rfc-style;
    };
}
