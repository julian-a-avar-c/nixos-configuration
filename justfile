default:
  just --list

save-progress:
  git add .

# TODO: Add to "update" group
update-everything:
  #!/usr/bin/env bash
  if [ "$EUID" -ne 0 ]
    then echo "Please run as root to update NixOS"
    exit
  fi
  just last-generation
  just update-flake-lock
  just save-progress
  just apply-update
  just last-generation

update-flake-lock:
  nix flake update

apply-update:
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
