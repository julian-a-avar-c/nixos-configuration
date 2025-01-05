default:
  just --list

save-progress:
  git add .

update-everything: save-progress
  #!/usr/bin/env bash
  if [ "$EUID" -ne 0 ]
    then echo "Please run as root to update NixOS"
    exit
  fi
  just last-generation
  nixos-rebuild switch --flake .

list-generations:
  nixos-rebuild list-generations

last-generation:
  just list-generations | head -2

# TODO: Add to mnc
clean:
  git clean -fdX

# TODO: Add as option of clean
clean-dry-run:
  git clean -ndX

git-log:
  git log --oneline --graph --decorate
