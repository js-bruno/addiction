# Servidor Minecraft NeoForge 1.21.4 no NixOS

Infraestrutura declarativa usando [nix-minecraft](https://github.com/Infinidoge/nix-minecraft).

## Arquivos

| Arquivo | Função |
|---|---|
| `minecraft-server.nix` | Módulo principal — configuração completa do servidor |
| `flake-example.nix` | Como adicionar ao seu `flake.nix` |
| `fetch-hashes.sh` | Script auxiliar para buscar hashes dos mods |

---

## Setup inicial (passo a passo)

### 1. Adicione o input ao seu flake.nix

```nix
inputs = {
  nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  nix-minecraft.url = "github:Infinidoge/nix-minecraft";
  nix-minecraft.inputs.nixpkgs.follows = "nixpkgs";
};
```

Passe `inputs` como `specialArgs`:

```nix
nixosConfigurations.meuservidor = nixpkgs.lib.nixosSystem {
  specialArgs = { inherit inputs; };
  modules = [
    ./configuration.nix
    ./minecraft-server.nix
  ];
};
```

### 2. Busque os hashes dos mods

O NixOS exige hashes verificados para garantir reprodutibilidade. Use o
utilitário do nix-minecraft para cada mod:

```bash
nix run github:Infinidoge/nix-minecraft#nix-modrinth-prefetch -- gTYCIFFQ
```

Isso imprime o bloco `fetchurl { ... }` com `sha512` pronto para colar no `.nix`.

Ou rode o script incluso que faz isso para todos de uma vez:

```bash
bash fetch-hashes.sh
```

Para encontrar o Version ID de um mod no Modrinth:
1. Acesse `modrinth.com/mod/<nome>/versions`
2. Filtre por NeoForge + 1.21.4
3. Clique na versão → copie o **Version ID** (ex: `gTYCIFFQ`)

### 3. Substitua os `lib.fakeHash` no `minecraft-server.nix`

Cada `sha512 = lib.fakeHash;` deve ser substituído pelo hash real obtido no passo 2.

### 4. Configure o servidor

Edite `minecraft-server.nix` e ajuste:

- `jvmOpts` — RAM disponível (`-Xms` / `-Xmx`)
- `serverProperties.max-players`
- `serverProperties.online-mode` — `false` para modo offline
- `operators` — adicione seu UUID de jogador
- `serverProperties."rcon.password"` — se quiser admin remoto

### 5. Aplique

```bash
sudo nixos-rebuild switch
```

---

## Gerenciamento do servidor

### Conectar ao console

```bash
tmux -S /run/minecraft/survival.sock attach
```

Desconectar sem parar o servidor: **Ctrl+b** depois **d**

### Parar / iniciar / reiniciar

```bash
sudo systemctl stop  minecraft-server-survival
sudo systemctl start minecraft-server-survival
sudo systemctl restart minecraft-server-survival
```

### Ver logs em tempo real

```bash
sudo journalctl -fu minecraft-server-survival
```

### Aplicar mudanças de config sem reiniciar

Se `enableReload = true` (padrão neste arquivo):

```bash
sudo nixos-rebuild switch  # re-linka mods e configs sem dar stop no server
```

---

## Adicionar mais mods

1. Encontre o mod em [modrinth.com](https://modrinth.com) — certifique-se que suporta **NeoForge 1.21.4**
2. Busque o hash: `nix run github:Infinidoge/nix-minecraft#nix-modrinth-prefetch -- <VERSION_ID>`
3. Adicione no `minecraft-server.nix`:

```nix
meuMod = modrinthMod {
  url    = "https://cdn.modrinth.com/data/PROJ_ID/versions/VERSION_ID/mod.jar";
  sha512 = "sha512-HASH_AQUI";
};
```

4. Inclua `meuMod` na lista dentro de `pkgs.linkFarmFromDrvs "mods" [ ... ]`
5. `sudo nixos-rebuild switch`

---

## Mods incluídos

| Mod | Versão | Propósito |
|---|---|---|
| FerriteCore | 7.1.2 | Reduz uso de RAM em até 40% |
| ModernFix | 5.20.3 | Startup rápido, correções de bugs, menos RAM |
| ServerCore | última p/ 1.21.4 | TPS otimizado, mob caps dinâmicos |
| Clumps | última p/ 1.21.4 | Agrupa orbs de XP → menos lag em farms |
| Waystones | última p/ 1.21.4 | Fast travel para survival |
| JEI | última p/ 1.21.4 | Browser de receitas |

---

## Dados do servidor

Os dados ficam em `/srv/minecraft/survival/`. Faça backup desta pasta regularmente.

```bash
# Backup simples
sudo tar -czf minecraft-backup-$(date +%Y%m%d).tar.gz /srv/minecraft/survival/world
```

---

## Segurança — RCON e senha

**Nunca** coloque senhas diretamente no `.nix` (vão para o Nix store público).
Use [sops-nix](https://github.com/Mic92/sops-nix) ou [agenix](https://github.com/ryantm/agenix):

```nix
# Com sops-nix:
services.minecraft-servers.environmentFile = config.sops.secrets."minecraft-env".path;
# No arquivo de env:
# RCON_PASSWORD=minhasenha_secreta
```
