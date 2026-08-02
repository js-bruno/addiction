# Conhecimento do Setup NixOS

Índice do repositório `/etc/nixos` — referência rápida para não esquecer como está montado e onde mexer.

---

## Estrutura de arquivos

```
/etc/nixos/
├── flake.nix              # Entrada do flake — declara inputs e o sistema
├── flake.lock             # Travamento das versões dos inputs
├── configuration.nix      # Configuração principal do SO
├── desktop.nix            # Configuração de vídeo/desktop (Nvidia + X + i3)
├── hardware-configuration.nix  # Hardware (gerada, mas editada)
├── mineserver_forge.nix   # Servidor Minecraft NeoForge 1.21.4
├── Makefile               # Atalho: collect-garbage
├── nix_test/              # Pequeno experimento nix-instantiate
│   ├── default.nix (implícito)
│   └── makefile
├── utils/
│   ├── fetch-hashes.sh          # Busca hashes de mods Modrinth
│   ├── nix_mine.md             # Doc do servidor Minecraft
│   └── minecraft_ssh_tunnel.md # Comando túnel SSH p/ MC
├── dilma.png              # Meme (sem função)
├── README.md              # To-do: modularizar config
└── SETUP.md               # Este arquivo
```

---

## Como o sistema é construído

`flake.nix` é a porta de entrada:

```nix
inputs = {
  nixpkgs      = "github:NixOS/nixpkgs/nixos-unstable";   # rolling unstable
  nix-minecraft = "github:Infinidoge/nix-minecraft";        # usa nixpkgs do flake
};

nixosConfigurations.nixos = nixosSystem {
  system = "x86_64-linux";
  modules = [ ./configuration.nix ./mineserver_forge.nix ];
};
```

- `nixpkgs` segue **unstable** — fique atento a quebras.
- `specialArgs = { inherit inputs; }` repassa `inputs` p/ `mineserver_forge.nix` (necessário p/ `inputs.nix-minecraft`).
- Aplicar: `sudo nixos-rebuild switch` (usa flake).
- Limpar gerações antigas: `make collect-garbage` → `nix-collect-garbage --delete-older-than 7d`.

---

## configuration.nix — pontos-chave

### Geral
- `imports = [ ./hardware-configuration.nix ./desktop.nix ]` — desktop e hardware entram pelaqui.
- `time.timeZone = "America/Fortaleza"` (Brasil, UTC−3).
- `stateVersion = "25.05"`.
- `nix.settings.experimental-features = [nix-command flakes]` — flakes ligados.
- `permittedInsecurePackages = [ "electron-36.9.5" ]` — workaround p/ pacote legado.

### Usuário
- `lacon` — usuário normal, shell `zsh`.
- Grupos: `input, uinput, docker, networkmanager, wheel, libvirtd` (admin + docker + uinput p/ joycons).
- `users.defaultUserShell = zsh`.

### Fontes
- `monocraft` + vários `nerd-fonts` (blex-mono, go-mono, agave, iosevka-term, etc).

### Programs habilitados (nível de sistema)
| Programa | Nota |
|---|---|
| firefox | |
| zsh | |
| gamemode | Otimização p/ jogos |
| java | Necessário p/ Minecraft |
| thunar / xfconf | Gerenciador de arquivos XFCE |
| virt-manager | Libvirt + virt-manager |
| appimage (binfmt) | Roda .AppImage |
| steam | remotePlay abre firewall; dedicated server não |

### Virtualização
- `libvirtd` + `spiceUSBRedirection` p/ VMs (USB redirecionamento).
- Docker **rootless** (socket + DNS 1.1.1.1/8.8.8.8 + mirror GCR).
  - `virtualisation.docker.enable = false` mas `rootless.enable = true` — rootless toma precedência.

### Serviços
| Serviço | Propósito |
|---|---|
| hermes-agent | Roda com `anthropic/claude-sonnet-4`; secret `sops.secrets."hermes-env"` |
| qbittorrent | |
| pipewire (alsa, 32bit, pulse, wireplumber) | Áudio moderno (substitui PulseAudio) |
| pulseaudio | `enable=false` (lógica) |
| resolved | DNS stub OFF, fallback 8.8.8.8/8.8.4.4 |
| jellyfin | Streaming, firewall aberto |
| input-remapper | Remapear gamepads/teclado |
| printing | CUPS |
| flatpak | |
| udev | Regra `uinput` group/mode p/ joycons |

### Rede
- `hostName = "nixos"`.
- `networkmanager` com perfis: wired "Conexão cabeada 1" (eth0, autoprrio 10) + wifi "Jose 2" (autoprrio −10).
- IP estático eth0: `192.168.1.99/24`, gateway `192.168.1.1`, DNS `1.1.1.1 8.8.8.8`.
- `useDHCP = false` — IP fixo (DHCP vem via NetworkManager profile).
- `hosts`: muitos `.homelab.local` mapeados para `127.0.0.1` (vikunja, grafana, uptime, mealie, vault, homepage, media, zbruno.blog.com.br), + `raw.githubusercontent.com` hardcode IP GitHub.

```ponytail
Os hosts .homelab.local apontam p/ 127.0.0.1 → presume que serviços rodam localmente.
Se mover homelab p/ container/VM separada, refazer esses mapeamentos.
```

### i18n
- Default `pt_BR.UTF-8`; `supportedLocales` inclui `ru_RU.UTF-8` também.
- Todos os `LC_*` definidos como pt_BR.

### Packages (systemPackages — só destaques)
- **Dev**: zed-editor, neovim, gh, git, lazygit, docker-compose, lazydocker, hugo, sqlite, sqlitebrowser, visidata, mongosh, vi-mongo, gopls, golangci-lint, nodejs_24, typescript-language-server, vue-language-server, gcc, libgcc, gnumake, python3, go, lua, lua-language-server, uv, nixd.
- **Browser**: firefox (sistema), chromium, nyxt, vivaldi, qutebrowser, librewolf.
- **Terminal**: alacritty, ghostty, wezterm, kitty, tmux, btop, dysk, ncdu, fzf, zoxide, freshfetch, hyperfine, flameshot, xclip, ripgrep.
- **Games**: steam, lutris, heroic, protonup-qt, protonplus, bottles, wine64, wine, winetricks, qemu, joycond, jstest-gtk, vulkan-tools.
- **Mídia**: mpv, vlc, plex, jellyfin, jellyfin-web, jellyfin-ffmpeg, kdePackages.kdenlive, spotify.
- **Outros**: discord-ptb, obsidian, gnome-tweaks, adw-gtk3, colloid-gtk-theme, yaru-theme, gnome-boxes, gnome-feeds, newsflash, blanket, gearlever, lmstudio, hermes-agent, mission-center, lm_sensors, gparted, testdisk, ntfs3g, android-tools, dbeaver-bin, dig, v4l-utils.
- `EDITOR = /run/current-system/sw/bin/nvim`.

### Variável gamepad
`SDL_GAMECONTROLLERCONFIG` com mapping p/ "Generic PS3 Controller" — catalisa o joycond. Se trocar controle, re-mapear via `evdev-joystick` ou SDL gamepad tool.

---

## desktop.nix — Ambiente gráfico

### Variáveis de sessão (Nvidia)
```nix
LIBVA_DRIVER_NAME = "nvidia";
__GLX_VENDOR_LIBRARY_NAME = "nvidia";
WLR_NO_HARDWARE_CURSORS = "1";   # workaround cursor em Wayland
```

### xserver (Xorg)
- `videoDrivers = [ "nvidia" ]`.
- `defaultSession = "lxqt"` (sessão padrão via GDM).
- `gdm.enable = true` — GDM é o display manager.
- Desktops habilitados: **gnome**, **lxqt** (default), **xfce**, **xterm**.
- Window manager: **i3** + extras (rofi, feh, i3status, i3lock, picom, polybar).
- `xkb.layout = "us"` (teclado US, sem variant).

### picom (compositor)
- `vSync = true`, `backend = "glx"` — composição Nvidia.
- `glx-no-stencil = true`, `glx-copy-from-front = false`.

### Packages desktop
pavucontrol, alttab, xfce4-whiskermenu-plugin, xfce4-docklike-plugin, lxqt.pavucontrol-qt, lxqt.pcmanfm-qt, lxqt.qterminal, xarchiver.

```ponytail
GDM roda + lxqt default, gnome/xfce/i3 também disponíveis → usuário escolhe na tela de login.
Para Wayland puro, requer Sway/Niri; atualmente X11-only via xserver.
```

---

## hardware-configuration.nix — hardware

### Boot
- `loader.systemd-boot.enable = true` + `efi.canTouchEfiVariables = true` — UEFI, systemd-boot.
- `tmp.useTmpfs = true`, `tmp.tmpfsSize = "10G"` — `/tmp` em tmpfs (RAM).
- `kernelModules = [ "uinput" "kvm-amd" ]` — AMD KVM p/ virtualização + uinput.
- **sysctl**: range portas não-privilegiadas 50–80 (algum serviço bindando abaixo de 1024), e IPv6 desabilitado em all/default/eth0.

```ponytail
IPv6 desligado globalmente. Se algum serviço precisar IPv6, reabilitar via sysctl.
```

### initrd
- `availableKernelModules = [xhci_pci ahci usbhid usb_storage sd_mod]` — suporte de boot.
- `kernelModules = []`, `extraModulePackages = []`.

### FileSystem (UUIDs — não mudam)
| Montagem | FS | Notas |
|---|---|---|
| `/` | ext4 | root |
| `/boot` | vfat | EFI, fmask/dmask 0077 |
| `/home` | ext4 | home separado — permite reinstalar SO preservando dados |
| `/nix` | ext4 | nix store separado |
| `/mnt/hard-disk` | ext4 | opções `auto nofail` |

### Swap e zram
- `swapDevices = []` — sem swap em disco.
- `zramSwap.enable = true, memoryPercent=50` — swap em RAM comprimida (limitado a 50% da RAM).

### Hardware
- `hostPlatform = "x86_64-linux"`.
- `hardware.steam-hardware.enable = true`.
- `cpu.amd.updateMicrocode` (via redistributable firmware).
- `hardware.graphics.enable + enable32Bit` (Vulkan/GL p/ jogos 32-bit).
- `hardware.uinput.enable = true`.
- **Nvidia**:
  - `modesetting.enable = true`.
  - `powerManagement.enable = false` (comentário avisa: causa sleep/suspend falhar).
  - `powerManagement.finegrained = false`.
  - `open = false` — usa driver proprietário, não o open-gpu-kernel-modules.
  - `nvidiaSettings = true`.
  - `package = kernelPackages.nvidiaPackages.stable`.

```ponytail
Arquivo gerado por `nixos-generate-config` mas editado (fs, nvidia, swap, sysctl).
Se rodar `nixos-generate-config` denovo, vai sobrescrever — sempre diff antes de aceitar.
home e /nix separados facilitam reinstalação.
```

---

## mineserver_forge.nix — Servidor Minecraft

### Setup do flake
- Importa `inputs.nix-minecraft.nixosModules.minecraft-servers`.
- Aplica overlay `inputs.nix-minecraft.overlay`.

### Servidor "survival"
- `package = pkgs.neoforgeServers.neoforge-1_21_4` — NeoForge 1.21.4.
- `autoStart = true`, `eula = true`, `openFirewall = true` (porta 25565).
- `enableReload = true` — symlinks/configs atualizam sem reiniciar o server.

### JVM
- `-Xms4G -Xmx4G` — fixo em 4GB.
- Flags Aikar's (G1GC, ParallelRefProcEnabled, MaxGCPauseMillis=200, AlwaysPreTouch, G1 tuning, etc) — receita consolidada para MC.

```ponytail
4GB fixo — ajustar conforme RAM total do host. Para mais players/mundos grandes, subir -Xmx.
Flags Aikar são a referência: https://mcflags.emc.gs
```

### serverProperties
- `server-ip = 0.0.0.0`, `server-port = 25565`.
- `online-mode = false` — servidor pirata/offline.
- `difficulty = normal`, `gamemode = survival`, `max-players = 20`, `spawn-protection = 16`.
- `view-distance = 15`, `simulation-distance = 12`.
- `sync-chunk-writes = false` (async I/O).
- `use-native-transport = true`.
- `max-tick-time = 60000` (60s, tolerante p/ lag spikes).
- `white-list = false`, `enable-rcon = false`.

### Mods (NeoForge 1.21.4)
Cada mod é `fetchurl { url; sha512; }` e montado em `symlinks.mods` via `linkFarmFromDrvs`.

| Mod | Versão | Função |
|---|---|---|
| FerriteCore | 7.1.3 | Reduz RAM |
| ModernFix | 5.20.3 | Startup + bug fixes |
| ServerCore | 1.5.8 | TPS, mob caps dinâmicos |
| Clumps | 22.0.0.1 | Agrupa XP orbs |
| Waystones | 21.4.19 | Fast travel |
| Balm | 21.4.42 | Lib p/ Waystones |
| JEI | 20.0.0.4 | Recipe browser |
| TreeHarvester | 9.1 | Corta árvore inteira |
| Collective | 8.3 | Lib (deps) |

### Configs de mods (em `files`)
- `config/servercore.toml`: `min_simulation_distance=4`, `dynamic_mob_caps=true`, threshold 18.0 TPS.
- `config/modernfix-common.toml`: `dynamic_resources.enabled = true` (carregamento lazy de recursos).

### Como adicionar mod
1. Achar no [modrinth.com](https://modrinth.com) filtrando NeoForge 1.21.4.
2. Copiar **Version ID** (botão na página da versão).
3. `nix run github:Infinidoge/nix-minecraft#nix-modrinth-prefetch -- <VERSION_ID>` — imprime bloco `fetchurl` pronto.
4. Colar no `mineserver_forge.nix`, adicionar drv na lista `linkFarmFromDrvs`.
5. `sudo nixos-rebuild switch` (com `enableReload` não reinicia).

```ponytail
Para mod com config própria, adicionar em `files` (TOML/JSON suportados via .value).
Data do mundo fica em /srv/minecraft/survival/ — backup é manual, fora do Nix.
```

### Operação
- **Console**: `tmux -S /run/minecraft/survival.sock attach` → Ctrl+b, d p/ detach.
- **Logs**: `sudo journalctl -fu minecraft-server-survival`.
- **Start/stop/restart**: `sudo systemctl [start|stop|restart] minecraft-server-survival`.

### Túnel remoto
`utils/minecraft_ssh_tunnel.md`:
```
ssh -R 25565:localhost:25565 lacon@191.252.38.145 -N
```
Expõe porta 25565 local sob o IP remoto (191.252.38.145) via reverse SSH tunnel.

```ponytail
191.252.38.145 é IP público — expõe MC p/ internet. Se não quiser expor, fechar túnel ou usar firewall p/ bloquear.
Senha RCON via variável de ambiente (sops-nix), nunca no .nix (vai p/ nix store público).
```

---

## utils/fetch-hashes.sh

Script bash que roda `nix-modrinth-prefetch` para cada mod listado.

- Formato do array: `"Nome|VersionID|Descrição"`.
- `MODS` → roda prefetch.
- `MODS_PENDENTES` → só imprime URL p/ buscar manualmente.
- Erro por-input não aborta (`|| echo [ERRO]`).

```ponytail
Lista hardcoded — adicionar mod novo = editar o script e o .nix.
Poderia ser uma única fonte de verdade (flakes com mod list), mas esse setup mantém separado.
```

---

## nix_test/

Pequeno sandbox p/ validar Nix expressions.

- `nix_test/makefile`:
  - `make run` → `nix-instantiate --eval` (avalia default.nix).
  - `make debug` → `nix-instantiate --eval --strict` (força avaliação).

```ponytail
Útil p/ testar funções/expressões isoladas antes de jogar nos módulos do SO.
```

---

## README.md

To-do list não concluída:
- divider visual (`vine11.gif` do pixelsafari).
- [ ] **Modulizar configuration** — meta declarada mas não executada. configuration.nix já tem ~250 linhas; candidates p/ extrair: `services`, `networking`, `packages`.

---

## Comandos frequentes

| Comando | O que faz |
|---|---|
| `sudo nixos-rebuild switch` | Aplica config (via flake atual) |
| `make collect-garbage` | Limpa gerações >7 dias |
| `nix run github:Infinidoge/nix-minecraft#nix-modrinth-prefetch -- <ID>` | Busca hash de mod Modrinth |
| `bash utils/fetch-hashes.sh` | Busca hashes em batch |
| `tmux -S /run/minecraft/survival.sock attach` | Console do servidor MC |
| `ssh -R 25565:localhost:25565 lacon@191.252.38.145 -N` | Tunela MC p/ IP público |
| `cd nix_test && make run` | Avalia expression de teste |

---

## Armadilhas conhecidas / Decisões pendentes

1. **nixpkgs unstable** → pode quebrar a qualquer momento. Considerar dual setup ou pinning.
2. **`electron-36.9.5` em permittedInsecurePackages** → vulnerável mas liberado. Subir versão quando possível.
3. **IPv6 totalmente off** → quebra alguns serviços modernos. Se deficiência, reabilitar sysctl.
4. **Nvidia power management off** → sleep/suspend pode dark screen ao acordar. Ativar `powerManagement.enable = true` se problema.
5. **Nvidia driver stable, `open = false`** → para Turing+ pode testar open modules (`open = true`).
6. **Docker rootless** → containers não enxergam serviços rootful por padrão. Se precisar, revisar socket forwarding.
7. **`raw.githubusercontent.com` hardcoded IP** → GitHub muda IPs (CDN), pode quebrar. Considerar DNS resolução normal.
8. **README pede modularização** → quando configuration.nix crescer mais, vale quebrar em módulos `services/`, `networking/`, `packages/`.
9. **`dilma.png`** no repo → meme sem função, ideal mover fora do config.
10. **DNS `1.1.1.1` hardcoded em 3 lugares** (docker daemon, networking, resolved). Considere `let` binding p/ DRY.

---

## Fluxo mental do sistema

```
flake.nix (inputs: nixpkgs unstable + nix-minecraft)
    │
    ▼
configuration.nix ──import──> hardware-configuration.nix (boot, fs, nvidia, sysctl)
    │                       └─ /home separado, zram 50%, AMD KVM
    ├──import──> desktop.nix (gdm + lxqt default + nvidia + i3 + picom)
    │
    └──> users, packages, services, networking
                                    │
                                    └─> NetworkManager profiles + IP fixo

flake.nix ──module──> mineserver_forge.nix
                    (nix-minecraft) ────> NeoForge 1.21.4
                                     └─ mods via fetchurl + linkFarm
                                     └─ Aikar's flags, async I/O, reload sem restart
```

---

## Notas finais

- Setup sólido para desktop gaming + dev + homelab local + servidor MC.
- Ponto mais sensível: `nixpkgs unstable` — manter `flake.lock` atualizado mas com cuidado p/ regressões.
- Segredo (hermes-env) via sops-nix — não comitar `.sops.yaml` ou secrets.
- Backups: `/srv/minecraft/survival/world` + `/home/lacon` + configs deste repo. `/nix` regenera do flake.

Para qualquer mudança: editar .nix correspondente → `sudo nixos-rebuild switch` → testar → commit no git.
