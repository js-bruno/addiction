# Perfil do Usuário — José Bruno (`lacon`)

> Documento de contexto para assistentes (opencode) e para mim mesmo.
> Derivado da configuração NixOS em `/etc/nixos`.

---

## Quem sou

- **Nome / handle**: José Bruno — usuário `lacon`
- **Local**: Ceará, Brasil — fuso `America/Fortaleza`, locale `pt_BR.UTF-8`
- **Idioma**: Português (responda em PT-BR)
- **Ocupação**: Dev **pleno** em um **marketplace**
- **Perfil**: **Fullstack** — transito por toda a stack web
- **Especialidade**: **Go** (backend é o meu forte)

---

## Stack & Linguagens

| Área | Ferramentas |
|---|---|
| **Go** (especialidade) | `go`, `gopls`, `golangci-lint` |
| **Frontend** | `nodejs_24`, `typescript-language-server`, `vue-language-server` (Vue) |
| **Python** | `python3`, `uv` |
| **Lua** | `lua`, `lua-language-server` |
| **Bancos** | MongoDB (`mongosh`, `vi-mongo`), SQLite (`sqlite`, `sqlitebrowser`), `dbeaver-bin` |
| **Infra / IaC** | Nix + Flakes, `devenv`, `nixd`, Docker rootless, `docker-compose`, `lazydocker` |
| **Editores** | Neovim (`$EDITOR`), Zed |
| **Build/toolchain** | `gcc`, `libgcc`, `gnumake` |

### Ambiente
- NixOS **unstable**, flakes habilitados, config declarativa em `/etc/nixos`
- Docker **rootless**, QEMU/libvirt/virt-manager, GNOME Boxes
- Prefere reprodutibilidade (`flake.lock` commitado, `follows` no nixpkgs)

---

## Terminal & Workflow

- **Shell**: zsh (+ autosuggestions, zoxide)
- **Emuladores**: alacritty, ghostty, wezterm, kitty (testa os 4)
- **Multiplexer**: tmux
- **TUI/CLI que uso**: `fzf`, `ripgrep`, `lazygit`, `lazydocker`, `btop`, `ncdu`, `dysk`, `hyperfine`, `television`, `visidata`, `freshfetch`
- **IA / dev assistido**: `opencode`, `lmstudio` (LLM local), agente Hermes
- **Editores**: Neovim como principal, Zed como alternativa

---

## Interesses técnicos

- **Backend Go** — foco principal
- **Homelab self-hosted** — serviços mapeados em `*.homelab.local` (127.0.0.1):
  Vikunja, Grafana, Uptime Kuma, Mealie, Vault, Homepage, mídia (Jellyfin/Plex)
- **Mídia/streaming**: Jellyfin, Plex, qBittorrent, Kdenlive, mpv/vlc
- **Blog pessoal**: `zbruno.blog.com.br` — usa **Hugo** (SSG)
- **Gaming / emulação**: Steam, Lutris, Heroic, Wine/Bottles, Proton; **servidor Minecraft NeoForge** declarativo via `nix-minecraft`
- **Privacidade**: vários browsers — Librewolf, qutebrowser, Nyxt (além de Firefox/Chromium/Vivaldi)
- **Estética**: fonte **Monocraft** (pixel/Minecraft) + nerd-fonts; temas Dracula, Kanagawa, Colloid, Yaru; memes no repo (`dilma.png`)
- **Idiomas**: curte russo (`ru_RU` nos locales) — provavelmente estudando

---

## Como eu penso (preferências)

- Gosto de analogias: meus docs de Nix comparam **Flakes = `go.mod`/`go.sum`** — penso muito em termos de Go
- Valoro **setup declarativo, reprodutível e limpo** (modularizar é meta em aberto no README)
- Uso muitas ferramentas modernas de terminal/TUI — prefira CLI a GUI quando possível
- Desktop: KDE Plasma + i3 (X11, Nvidia) + lxqt; GDM como display manager

---

## Diretrizes para assistentes

1. Responder em **português (PT-BR)**.
2. Assumir **fullstack** com viés **Go** — pode ser direto em backend, sem explicar o básico.
3. Em exemplos de infra/config, **preferir abordagem declarativa/reprodutível**.
4. Para Nix, código deve seguir o estilo do repo (flake + módulos, `with pkgs;`, sem comentários supérfluos no `.nix`).
5. Comandos destrutivos ou `nixos-rebuild switch` — confirmar antes.
6. Features de frontend: assumir **Vue + TypeScript** como padrão, salvo indicação contrária.

---

## Repositório `/etc/nixos` — mapa rápido

| Arquivo | Função |
|---|---|
| `flake.nix` / `flake.lock` | Entrada + pin de inputs (nixpkgs unstable) |
| `configuration.nix` | Config principal (users, packages, services, rede) |
| `desktop.nix` | Nvidia + X11 + KDE/i3/lxqt + GDM |
| `hardware-configuration.nix` | Boot, filesystems, zram, Nvidia |
| `mineserver_forge.nix` | Servidor Minecraft NeoForge 1.21.4 (mods Modrinth) |
| `docs/` | Notas pessoais (Flakes, setup, ideias de projeto) |
| `utils/` | Scripts auxiliares (hashes Modrinth, túnel SSH) |

**To-do declarado**: modularizar `configuration.nix` (~320 linhas).
