{ config, pkgs, ... }:
{
  programs.zsh = {
    enable = true;

    oh-my-zsh = {
      enable = true;
      plugins = [ "git" ];
      theme = "robbyrussell";
    };

    shellAliases = {
      dr = "sudo darwin-rebuild switch --flake ~/nix#${config.home.username}-${pkgs.stdenv.hostPlatform.system}";
    };

    initContent = ''
      setopt PROMPT_SUBST

      function update_prompt() {
        PROMPT=$'\n'

        if [[ $PWD != $HOME ]]; then
          PROMPT+="%F{#737994}%~%f"$'\n'
        fi

        PROMPT+="%F{#8caaee}%n%f %F{#f4b8e4}[λ]%f "
      }

      PS2="%F{#737994} [...]%f "

      autoload -U add-zsh-hook
      add-zsh-hook chpwd update_prompt
      update_prompt

      RPROMPT='%F{$CTP_OVERLAY0}$(git rev-parse --is-inside-work-tree 2>/dev/null && echo "git:") %F{$CTP_SURFACE2}$(git rev-parse --abbrev-ref HEAD 2>/dev/null)%f'

      ZSH_THEME_GIT_PROMPT_PREFIX="%F{$CTP_OVERLAY0}[git:"
      ZSH_THEME_GIT_PROMPT_SUFFIX="%f"
      ZSH_THEME_GIT_PROMPT_DIRTY="%F{$CTP_OVERLAY0}] ✖ %f"
      ZSH_THEME_GIT_PROMPT_CLEAN="%F{$CTP_OVERLAY0}] ✔%f"

      eval "$(zoxide init --cmd cd zsh)"

      ds() {
        emulate -L zsh
        setopt ERR_EXIT NO_UNSET PIPE_FAIL

        if [[ -e flake.nix ]]; then
          print -u2 "ds: flake.nix already exists here (won't overwrite)."
          return 1
        fi

        cat > flake.nix <<'EOF'
{
  inputs = {
    # FlakeHub nixpkgs: "0" tracks the current stable nixpkgs channel on FlakeHub
    nixpkgs.url = "https://flakehub.com/f/DeterminateSystems/nixpkgs-weekly/0.tar.gz";

    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            nodejs_24
            bun
            # pnpm
            gemini-cli
          ];

          shellHook = "
            echo \"Nix dev shell activated\"
            echo \"Node:  $(node --version 2>/dev/null || echo 'not found')\"
            echo \"Bun:   $(bun --version 2>/dev/null || echo 'not found')\"
          ";
        };
      }
    );
}
EOF

        # .envrc: ensure "use flake"
        touch .envrc
        grep -qx 'use flake' .envrc || print 'use flake' >> .envrc

        # .gitignore: ensure ".direnv"
        touch .gitignore
        grep -qx '\.direnv' .gitignore || print '.direnv' >> .gitignore

        # activate direnv
        if (( $+commands[direnv] )); then
          direnv allow
        else
          print -u2 "ds: direnv not found (install it + set up the shell hook)."
          return 1
        fi

        print "ds: done ✅"
      }

      autoload -Uz edit-command-line
      zle -N edit-command-line
      bindkey '^x^e' edit-command-line
    '';
  };
}
