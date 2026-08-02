# Flake - Dicas práticas de uso diário

Truques e workflows que você usa o tempo todo com flakes. Assume que você já leu `FLAKES_NIXOS.md`.

---

## Criar um flake novo do zero

```bash
mkdir meuprojeto && cd meuprojeto
nix flake init -t templates#go       # template oficial Go (tem py, rust, trivial...)
nix flake init                       # flake mínimo vazio
```

Se `templates` não funcionar (pode ser seu nixpkgs), use:
```bash
nix flake init -t github:NixOS/templates#go
```

---

## `nix` vs `flake` — dois comandos separados

| Comando antigo (sem flake) | Comando flake (sempre `nix` + flag) |
|---|---|
| `nix-channel --update` | `nix flake update` |
| `nix-env -iA nixpkgs.hello` | `nix profile install nixpkgs#hello` |
| `nix-shell -p go` | `nix develop` (ou `nix shell nixpkgs#go`) |
| `nix-build` | `nix build` |

Regra: se tem `flake` no nome (`flake.lock`, `flake.nix`), use o comando `nix` (não `nix-env`, `nix-channel`, `nix-shell`, `nix-build`). Esses antigos **ignoram** flakes.

---

## Atualizar inputs (como `go get -u`)

```bash
nix flake update                  # todos os inputs
nix flake lock --update-input nixpkgs  # só nixpkgs
nix flake lock --update-input nix-minecraft  # só um específico
```

Sempre commit o `flake.lock` depois — é o que trava as versões.

---

## Ver o que um flake oferece

```bash
nix flake show .                          # outputs deste flake
nix flake show github:Infinidoge/nix-minecraft  # outputs de um remoto
nix flake metadata .                     # inputs travados
```

---

## `.` vs `.#nome` — sintaxe

- `.` — o flake no diretório atual.
- `.#nome` — o output específico dentro desse flake.
- `.` — sem nada = output `default`.

Exemplos: `nix build .#default`, `nix develop .#meushell`, `nixos-rebuild switch -- flake .#nixos`.

Se você não passa nada: `nix build` → tenta `.#default`.

---

## `follows` — sempre que possível

Todo input que **também** depende de `nixpkgs` deve usar `follows`. Exemplo:

```nix
home-manager = {
  url = "github:nix-community/home-manager";
  inputs.nixpkgs.follows = "nixpkgs";
};
```

Sem isso, você terá **duas cópias do nixpkgs** no store (gigantesco). Se não tem `follows` e um flake quebrar pessoas com "nixpkgs mismatch", foi disso.

---

## Cache (binary cache) — a parte que ninguém explica

Se você puxar muitos inputs diferentes, o sistemas Nix **constrói tudo do source** (horas). Pra evitar:

1. **Verifique se o input expõe suas próprias caches** (ex: cachix)
   ```bash
   nix flake show github:Infinidoge/nix-minecraft | grep -i cachix
   ```
2. **Use o substituidor do nixCommunity**: `nix.settings.substitutors` configurado
3. **Com flake, cache é automático se `flake.lock` for mesmo**.

Se build demorado persistir, tente `nix build --verbose`.

---

## Editar `configuration.nix` sem floco - `sudo nixos-rebuild test/switch` vs test vs switch

Na ordem de fase:

```bash
sudo nixos-rebuild test              # testa, não salva boot entry, reverte no reboot
nixos-rebuild switch   # salva e aplica boot entry (padrão)
nixos-rebuild dry-activate  # só valida ganhos (não aplica)
```

Se estiver com medo de quebrar algo: teste sempre com `test` antes de `switch`.

Com nível de verbose:
```bash
sudo nixos-rebuild switch --show-trace   # se quebrar pra sabe onde
```

---

## Erro comum: `access to ... is forbidden`

Solução: certifique-se que o arquivo está **commitado** no git. Flakes são sensíveis a arquivos não comitados (para garantir reprodutibilidade). Use `git add` primeiro.

---

## `nix develop` vs `nix shell`

- `nix develop` → shell temporário com `flake.nix` `devShells` preset, também lê `.envrc` se existir.
- `nix shell nixpkgs#go` → baixa só GO e fecha o PATH.

Para abrir rapidamente:
```bash
# isto:
nix shell nixpkgs#go -c zsh

# (ou -c bash)
```

---

## Usar FLake para instalar um app único ao invés de poluir o sistema

```bash
nix profile install nixpkgs#ripdar  # instala ripdar user-local
nix profile list                     # lista o que já tem

nix run nixpkgs#hugo -- new site .  # roda hugo sem instalar

nix shell nixpkgs#ghc# -- ghci      # entra Haskell REPL temporário
```

---

## Reverter para geração antiga

O NixOS guarda gerações deite todo `switch`, e você pode voltar para qualquer uma:

```bash
sudo nixos-rebuild switch --rollback  # volta para a última

sudo nix-collect-garbage              # remove gerações não usadas
sudo nix-collect-garbage --delete-older-than 7d  # remove as antigas

# Mais especific: reverter para um generation específica
nix-env --list-generations
sudo nixos-rebuild --rollback switch  # equivalente a ctrl+z
```

---

## Como checar se a config vai compilar sem erro

```bash
nix flake check                     # usa checks. (inclui validação de tipos)
nix build .#nixosConfigurations.nixos.config.system.build.toplevel  # muito pesado

# Menos pesado:
nix eval .#nn{rnixosConfigurations.nixos.config.system.stateVersion
```

---

## Adicionar um input que é um arquivo local (tipo monkey-import)

Se outro de seus projetos expõe flake, pode importar como input local:

```nix
inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    meuprojeto.url = "path:../meuprojeto";  # local, fs relativa
};
```

Mas cuidado: **não use isso para NixOS** porque `path:` referência a um lugar fora do diretório e pode travar para sempre se mover o arquivo. Use em projetos de dev.

---

## Caches — adicione ao seu sistema

File: `/etc/nixos/configuration.nix`:

```nix
  nix.settings.substituters = [
    "https://nix-community.cachix.org"
  ];
  nix.settings.trusted-public-keys = [
    "nix-community.cach"
  ];
```

Depois `sudo nixos-rebuild switch` pra aplicar.

---

## `import` vs `callPackage` vs `self`

- `import ./file.nix` → carrega arquivo bruto de qualquer lugar (estilo imperativo)
- `pkgs.callPackage ./packages.nix {}` → carrega com argumentos padrão (nixpkgs)
- `self.outputType` → acessa output do próprio flake (ex: `self.packages.x86_64-linux.something`)

Use `callPackage` para compat cross-system; `import` para mod local (se você tem os argumentos lavados já).

---

## Debug output do flake

Mostrar todos os outputs do flake atual:
```bash
nix flake show
```

Mostrar o modelo nixos gerado (antes de `switch`):
```bash
nix eval .#nixosConfigurations.nixos.config.system.stateVersion
```

---

## Limpar recursos (quando fica pesado)

```bash
sudo nix-collect-garbage -d                    # limpa tudo antigo
sudo nix-collect-garbage --delete-older-than 7d # só >7d
nix store info                                   # vê uso atuual
```

O `Makefile` do repositório faz exatamente isso.

---

## Dicas avançadas de performance

- Prefira `follows` sempre — evita downloads desnecessários.
- Use `builtins.attrNames` p/ iterar sobre chaves, com desse de iteradores.
- `lib.evalModules` é útil para validar configurações complexas.
- Para um `fod` + check de saúde: `nix build .#checks -- --keep-failed`.

---

## TL;DR das dicas

| Ação | Comando |
|---|---|
| Criar flake do zero | `nix flake init` |
| Atualizar tudo | `nix flake update` |
| Atualizar input X | `nix flake lock --update-input X` |
| Ver outputs do flake | `nix flake show` ou `nix flake show github:repo` |
| Testar antes de aplicar | `sudo nixos-rebuild test` |
| Aplicar config | `sudo nixos-rebuild switch` |
| Reverter última config | `sudo nixos-rebuild switch --rollback` |
| Limpar disco | `sudo nix-collect-garbage -d` |
| Instalar app sem SO | `nix profile install nixpkgs#app` |
| Rodar app sem instalar | `nix run nixpkgs#app` |
| Entrar shell temporário | `nix shell nixpkgs#go -c bash` |
| Entrar devshell do flake | `nix develop` |

Lembre-se: **commite tudo** — flake é sensível a `git status` (uncommitted → erro).