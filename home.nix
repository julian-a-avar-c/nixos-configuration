{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "julian-a-avar-c";
  home.homeDirectory = "/home/julian-a-avar-c";

  home.packages = with pkgs; [
    # fortune
    unstable.librewolf
    unstable.libreoffice
    unstable.musescore
    unstable.muse-sounds-manager
    unstable.gimp
    unstable.godot_4
    unstable.thunderbird

	# English comes pre-installed.
    hunspellDicts.es_AR

    unstable.vscodium.fhs
    unstable.jetbrains-toolbox
    unstable.jetbrains.idea-community

    # Programming Languages:
    # - Lean 4     - elan
    # - Java       -
    temurin-bin
    # - Scala      -
    scala unstable.scala-cli unstable.sbt unstable.mill unstable.bleep unstable.bloop
    coursier unstable.metals
    # - C/C++      -
    clang scons cmake
    # - JavaScript -
    nodejs corepack
    # - Python     -
    python3 # python313Full
    poetry
    # - Lua        - lua
    # - Racket     - racket
    # - Julia      - julia-bin # Doesn't always work, use distrobox as workaround
    # - R          - R
    # - LaTeX      - texlive.combined.scheme-full
    # - Clojure    - clojure
    # - Antlr
    antlr4_12

    # TODO: sort
    pulumi-bin
    obsidian
    quicktype # TODO: For "godot-scala", I should remove this.
    kitty
    unstable.ladybird
    fd # I like it better than `find`
    ripgrep # It has good regex support compared to `grep`
    unstable.lmstudio # AI sandbox
    inetutils
  ];

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "24.11";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs.git = {
    enable = true;
    userName = "Julian A Avar C";
    userEmail = "julian-a-avar-c@proton.me";
  };
}
