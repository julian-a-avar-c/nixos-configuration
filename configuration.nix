{ config, lib, pkgs, ... }:

let
  # unstableTarball =
  #   fetchTarball
  #     https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz;
in {
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      # Disko
      # "${builtins.fetchTarball "https://github.com/nix-community/disko/archive/master.tar.gz"}/module.nix"
      ./disko-configuration.nix
    ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;
  # nixpkgs.config.packageOverrides = pkgs: {
  #   unstable = import unstableTarball {
  #     config = config.nixpkgs.config;
  #   };
  # };

  # boot.kernelPackages = pkgs.unstable.linuxPackages;
  # boot.kernelParams = [ "button.lid_init_state=open" ];
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  nixpkgs.overlays = [
    (final: prev: {
      openrazer-daemon = pkgs.unstable.openrazer-daemon;
    })
  ];

  # hardware.pulseaudio.enable = true; # KDE Audio Issues.
  # hardware.opengl.enable = true;
  # hardware.openrazer.enable = true;
  hardware.graphics.enable = true;
  hardware.nvidia.open = false; # I've heard that the open drivers are good enough these days
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
  # services.xserver.desktopManager.xterm.enable = false; # NOTE: I don't like XTerm
  # services.xserver.excludePackages = [ pkgs.xterm ]; # NOTE: I don't like XTerm
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
      unstable.librewolf
      unstable.libreoffice
      unstable.musescore
      unstable.muse-sounds-manager
      unstable.gimp
      unstable.godot_4

      unstable.vscodium.fhs
      unstable.jetbrains-toolbox

      unstable.endless-sky
      unstable.dwarf-fortress
      unstable.dwarf-fortress-packages.dwarf-fortress-full

      pulumi-bin

      # Programming Languages:
      # - Lean 4     - elan
      # - Java       -
      temurin-bin
      # - Scala      -
      scala unstable.scala-cli sbt unstable.mill unstable.bleep unstable.bloop
      coursier unstable.metals
      # - C/C++      -
      clang scons cmake
      # - JavaScript -
      nodejs corepack
      # - Python     - python3 python313 poetry
      # - Lua        - lua
      # - Racket     - racket
      # - Julia      - julia-bin # Doesn't always work, use distrobox as workaround
      # - R          - R
      # - LaTeX      - texlive.combined.scheme-full
      # - Clojure    - clojure
      # - Antlr
      antlr4_12

      # TODO: sort
      obsidian
      quicktype # TODO: For "godot-scala", I should remove this.
      kitty
      unstable.ladybird
    ];
  };

  environment.systemPackages = with pkgs; [
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
    jetbrains-toolbox
    unstable.zed-editor
    arduino-ide

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
  programs.steam.enable = true;
  programs.nano.enable = false; # NOTE: Only way to remove "nano"
  programs.mtr.enable = true; # TODO: Learn to use mtr, https://nixos.wiki/wiki/Mtr https://www.redhat.com/sysadmin/linux-mtr-command
  programs.gnupg.agent.enable = true;
  programs.gnupg.agent.enableSSHSupport = true;
  programs.nix-ld.enable = true;
  # Plasma
  programs.ssh.askPassword = pkgs.lib.mkForce "${pkgs.ksshaskpass.out}/bin/ksshaskpass";
  # Gnome
  # programs.ssh.askPassword = pkgs.lib.mkForce "${pkgs.gnome.seahorse.out}/libexec/seahorse/ssh-askpass";

  system.stateVersion = "24.11";
}
