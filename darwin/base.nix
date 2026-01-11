{ self, username }:
{ ... }:
{
  imports = [
    ./activation.nix
    ./defaults.nix
    ./fonts.nix
    ./packages.nix
    ./users.nix
    ./window-manager.nix
  ];

  system.stateVersion = 6;
  system.configurationRevision = self.rev or self.dirtyRev or null;
  system.primaryUser = username;

  nixpkgs.config.allowUnfree = true;
}
