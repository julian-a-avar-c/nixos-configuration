{ config, lib, pkgs, ... }:

{
  options = {
    my-options = {

      enable = lib.mkOption {
        type = lib.mkEnableOption (lib.mdDoc "My options");
        default = false;
      };

      desktop-environment = lib.mkOption {
        type = with lib.types; nullOr (enum [ "plasma" "gnome" ]);
        default = "none";
        description = "A single place to change the desktop environment according to my own preferences.";
      };

    };
  };

  config = let

    config-options = {

      programs.ssh.askPassword =
        {
          "plasma" = "${pkgs.ksshaskpass.out}/bin/ksshaskpass";
          "gnome" = "${pkgs.gnome.seahorse.out}/libexec/seahorse/ssh-askpass";
        }.${config.my-options.desktop-environment};

    };

  in lib.mkIf (config.my-options.enable) {

    programs.ssh.askPassword = pkgs.lib.mkForce
      config-options.programs.ssh.askPassword;

  };
}
