# AGENTS.md

NixOS flake homelab -- single host `hashida-itaru` (Dell XPS 13 9350, x86_64-linux).

## Commands

| What | Command |
|---|---|
| Full validation | `nix flake check` |
| Build system | `nix build '.#nixosConfigurations.hashida-itaru.config.system.build.toplevel'` |
| Build one package | `nix build '.#packages.x86_64-linux.<name>'` |
| Evaluate config | `nix eval '.#nixosConfigurations.hashida-itaru'` |
| Deploy on target | `sudo nixos-rebuild switch --flake '/path/to/repo#hashida-itaru'` |

No devShell, test runner, linter, typechecker, or formatter. CI runs `nix flake check`. Dependabot auto-merges weekly Nix dep bumps via squash.

## Structure

- `hosts/<host>/` -- per-machine configs (modules auto-imported via `scanPaths`)
- `lib/` -- shared Nix functions (`nixosSystem`, `relativeToRoot`, `scanPaths`)
- `modules/services/` -- reusable NixOS service definitions (auto-imported)
- `packages/<name>/package.nix` -- custom derivations (auto-discovered)
- `secrets/*.age` -- agenix-encrypted secrets (only 2: anki-sync, nas-account)
- `lib/nixosSystem.nix` -- base system builder (SSH, user, networking, bootloader)

No `shell.nix` / `devShells`.

## Conventions

- **`scanPaths`** auto-imports all `.nix` files (except `default.nix`) and directories. Adding a `.nix` file under `hosts/<host>/`, `modules/services/`, or `packages/<name>/` is enough to wire it in -- no manual import list.
- **Package derivations** must be at `packages/<name>/package.nix`. Discovered by `scanPaths` + `callPackage`.
- **Service modules** follow: `with lib;` -> `options` -> `config` -> `mkIf cfg.enable`, create dedicated `user` + `group`, use `systemd.tmpfiles.rules` for dirs.
- **State version** `25.11`. Unfree enabled globally. `programs.nh` for Nix helper.
- **Domain**: `*.worldline.local` (mDNS). NAS at `192.168.1.10` via NFS.
- **Secrets**: **Two separate systems** -- (1) agenix: `.age` files decrypted at build via host SSH keys to `/run/secrets/`, only used by anki-sync. `nas-account.age` is defined but unused/dangling. (2) `/var/lib/secrets/`: plain files expected on-disk, used by bar-assistant, glance, home-assistant, freshrss -- NOT agenix-managed.
- **Reverse proxy**: Caddy (nginx disabled). Bootloader: systemd-boot.
- **Theme**: catppuccin mocha.
