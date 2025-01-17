{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      # Disko
      ./disko-configuration.nix
    ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelParams = [ "button.lid_init_state=open" ];
  boot.blacklistedKernelModules = [ "nouveau" ];
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # TODO: Put in flake.
  nixpkgs.overlays = [
    (final: prev: {
      openrazer-daemon = pkgs.unstable.openrazer-daemon;
    })
  ];

  # hardware.pulseaudio.enable = true; # KDE Audio Issues.
  hardware.openrazer.enable = true;
  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;
  hardware.nvidia.open = false;
  hardware.nvidia.modesetting.enable = true; # NixOS Wiki: "Modesetting is required."
  hardware.nvidia.nvidiaSettings = true;
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.stable;
  hardware.nvidia.powerManagement.finegrained = true;
  hardware.nvidia.prime = {
    # Sync mode
    # sync.enable = true;
    # Offload mode
    offload.enable = true;
    offload.enableOffloadCmd = true;
    # NOTE: Using specializations. Reboot to select the `on-the-go` option for better battery life.

    # Make sure to use the correct Bus ID values for your system!
    # intelBusId = "PCI:0:2:0";
    # nvidiaBusId = "PCI:14:0:0";
    # amdgpuBusId = "PCI:54:0:0"; For AMD GPU
    nvidiaBusId = "PCI:100:0:0";
    amdgpuBusId = "PCI:1:0:0";
  };
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  hardware.bluetooth.settings.General.Experimental = true;

  networking.hostName = "exilis-celebensis";
  networking.networkmanager.enable = true;

  time.timeZone = "America/New_York";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  virtualisation.containers.enable = true;
  # virtualisation.docker.enable = true;
  # virtualisation.docker.storageDriver = "btrfs";
  virtualisation.podman.enable = true;
  virtualisation.podman.dockerCompat = true;

  services.xserver.enable = true;

  # Gnome
  # services.xserver.displayManager.gdm.enable = true;
  # services.xserver.desktopManager.gnome.enable = true;
  # Plasma
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.desktopManager.plasma6.enable = true;

  services.xserver.xkb.layout = "us";
  services.xserver.xkb.variant = "";
  services.xserver.videoDrivers = [ "nvidia" ]; # Needed for brightness control
  services.xserver.desktopManager.xterm.enable = false; # NOTE: I don't like XTerm
  services.xserver.excludePackages = [ pkgs.xterm ]; # NOTE: I don't like XTerm
  services.printing.enable = true;
  services.avahi.enable = true; # Enable autodiscovery of network printers
  services.avahi.nssmdns4 = true; # Enable autodiscovery of network printers
  services.avahi.openFirewall = true; # Enable autodiscovery of network printers
  services.pipewire.enable = true; # audio
  services.fstrim.enable = true; # SSD thing. See: https://man7.org/linux/man-pages/man8/fstrim.8.html
  services.flatpak.enable = true;
  # services.openssh.enable = true; # https://nixos.wiki/wiki/SSH
  # services.kubo.enable = true; # IPFS; https://wiki.nixos.org/wiki/IPFS


  # Don't forget to set a password with ‘passwd’.
  users.users."julian-a-avar-c" = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "docker"
      "podman"
      "openrazer"
      # config.services.kubo.group
      # "input" # https://www.reddit.com/r/linuxquestions/comments/bh4ex1/is_adding_a_user_to_input_group_secure/
      # "networkmanager" # TODO: What is this?
    ];
    packages = with pkgs; [

      unstable.endless-sky
      unstable.dwarf-fortress
      unstable.dwarf-fortress-packages.dwarf-fortress-full
    ];
  };

  environment.systemPackages = with pkgs; [
    home-manager

    geoclue2 # KDE night light

    openrazer-daemon
    polychromatic

    gnome-tweaks
    adwaita-icon-theme

    micro
    vim
    neovim
    vimPlugins.nvchad
    vimPlugins.nvchad-ui
    emacs # TODO: I should learn emacs
    emacsPackages.spacemacs-theme
    jetbrains.idea-community # ultimate
    unstable.zed-editor
    arduino-ide
    just

    appimage-run

    git
    git-lfs
    unstable.pijul

    nodePackages."@angular/cli"

    # docker
    podman
    distrobox

    wget
    eza # `ls` is a pain in the arse
    just

    nil
    nixd
  ];
  environment.variables = {
    SSH_ASKPASS_REQUIRE = "prefer";
  };

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans # What about serif!
    noto-fonts-emoji
    atkinson-hyperlegible
    fira-code
    fira-code-symbols
    nerdfonts
    google-fonts
  ];

  programs.bash.shellAliases.godot = "godot4";
  programs.bash.shellAliases.eza = "eza --icons";

  programs.steam.enable = true;
  programs.nano.enable = false; # NOTE: Only way to remove "nano"
  programs.mtr.enable = true; # TODO: Learn to use mtr, https://nixos.wiki/wiki/Mtr https://www.redhat.com/sysadmin/linux-mtr-command
  programs.nix-ld.enable = true;
  programs.ssh.startAgent = true;
  programs.ssh.enableAskPassword = true;

  # Plasma
  programs.ssh.askPassword = pkgs.lib.mkForce "${pkgs.ksshaskpass.out}/bin/ksshaskpass";
  # Gnome
  # programs.ssh.askPassword = pkgs.lib.mkForce "${pkgs.gnome.seahorse.out}/libexec/seahorse/ssh-askpass";

  # specialisation = {
  #   "on-the-go".configuration = {
  #     system.nixos.tags = [ "on-the-go" ];
  #     hardware.nvidia.prime = {
  #       offload.enable = lib.mkForce true;
  #       offload.enableOffloadCmd = lib.mkForce true;
  #       sync.enable = lib.mkForce false;
  #     };
  #   };
  # };

  system.stateVersion = "24.11";
}
