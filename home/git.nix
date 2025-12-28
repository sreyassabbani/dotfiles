{ config, pkgs, ... }:
{
  programs.git = {
    enable = true;

    signing = {
      key = "688241BB0F9A860B";
      signByDefault = true;
    };

    settings = {
      user = {
        name = "Sreyas Sabbani";
        email = "sreyassabbani@gmail.com";
      };

      gpg.program = "gpg";

      core = {
        editor = "hx";
        autocrlf = "input";
      };

      init.defaultBranch = "main";
      pull.rebase = true;
      merge.conflictstyle = "zdiff3";
      color.ui = "auto";
      commit.gpgsign = true;
      tag.gpgsign = true;

      alias = {
        sl = "log --oneline";
        st = "status -sb";
        co = "checkout";
        br = "branch";
        ci = "commit";
        lg = "log --oneline --graph --decorate --all";
      };
    };
  };
}
