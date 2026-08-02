# Flakes no NixOS — explicação direta

Analogia com Go (assumindo conhecimento básico de Nix e Go).

---

## O problema que flakes resolvem

Antes de flakes, você editava `/etc/nixos/configuration.nix` e rodava `nixos-rebuild`. O problema: **`niv`-style ou channels** — 
versões não travadas, reprodutibilidade quebrada, "na minha máquina funciona".

Flakes = **`go.mod` + `go.sum` para sua config NixOS**.

| Go | Nix Flake |
|---|---|
| `go.mod` | `flake.nix` |
| `go.sum` | `flake.lock` |
| `go get` | adicionar input em `flake.nix` |
| `go build` | `nix build` |
| `make install` | `nix profile install` |
| `go run main.go` | `nix run` |
| `GOPATH` | Nix store (`/nix/store`) |
| version pinning | `flake.lock` |

---

## Anatomia do `flake.nix`

Seu `flake.nix`:

```nix
{
  description = "My declartive nix-minecraft server with my os configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix-minecraft.url = "github:Infinidoge/nix-minecraft";
    nix-minecraft.inputs.nixpkgs.follows = "nixpkgs";  # reusa o nixpkgs do flake
  };

  outputs = { self, nixpkgs, nix-minecraft, ... }@inputs: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };  # repassa inputs p/ os módulos
      modules = [ ./configuration.nix ./mineserver_forge.nix ];
    };
  };
}
```

Termo a termo:

- **`inputs`** — dependências externas (tipo `require` em go.mod). 
Cada qual aponta p/ um repo git com ref/tag/branch. As versões ficam travadas em `flake.lock` (tipo `go.sum`).
- **`outputs`** — função que recebe `inputs` e devolve "o que o flake oferece". Pode oferecer: pacotes, apps, devShells, nixosConfigurations, overlays, etc. Aqui só oferece `nixosConfigurations.nixos`.
- **`nixpkgs.lib.nixosSystem`** — função que monta um sistema NixOS a partir de uma lista de módulos.
- **`specialArgs = { inherit inputs; }`** — injeta `inputs` no escopo de todos os módulos (igual passar argumentos p/ um middleware Go). É por isso que `mineserver_forge.nix` consegue acessar `inputs.nix-minecraft`.
- **`modules`** — lista de arquivos `.nix` que configuram o sistema (igual pipeline de middlewares encadeados).

### Por que `follows`?

```nix
nix-minecraft.inputs.nixpkgs.follows = "nixpkgs";
```

Sem isso, `nix-minecraft` traria **sua própria cópia do nixpkgs** (uma versão diferente da sua) → binaries duplicados, conflitos. Com `follows`, ele usa **exatamente o mesmo nixpkgs que você**. Em Go, seria como dizer "use my local module replacement".

---

## Exemplo 1: flake mínimo p/ um pacote

Imagine que você quer empacotar um programa Go simples. Crie `flake.nix`:

```nix
{
  description = "Meu app Go empacotado em Nix";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:    # função: inputs → outputs
    let
      # `forAllSystems` = helper p/ suportar x86_64 e aarch64
      forAllSystems = f: nixpkgs.lib.genAttrs ["x86_64-linux" "aarch64-linux"] (sys: f sys);

      # pkgs = nixpkgs handle para um sistema específico
      # (type: *nixpkgs com arch selecionada*, como `GOOS/GOARCH`)
      pkgsFor = system: nixpkgs.legacyPackages.${system};
    in {
      packages = forAllSystems (system: {
        default = (pkgsFor system).buildGoModule {
          pname = "meuapp";
          version = "0.1.0";
          src = ./.;                  # o dir atual vira source
          vendorHash = null;          # sem deps Go → null. Com deps, sha256 do /vendor.
        };
      });
    };
}
```

Rodar:
```bash
nix build .#default         # gera result/bin/meuapp
nix run .#default           # builda e executa direto
```

`.#default` = "<este flake> . <output packages.default>".

---

## Exemplo 2: devShell (substitui docker-compose p/ dev)

Muito útil — ambiente de dev reproduzível sem poluir o SO:

```nix
{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
    in {
      devShells.x86_64-linux.default = pkgs.mkShell {
        packages = with pkgs; [ go gopls golangci-lint ];
        shellHook = ''
          echo "Bem-vindo ao dev shell do meuapp"
          export GOPATH=$PWD/.gopath
        '';
      };
    };
}
```

Entrar no shell:
```bash
nix develop
# agora você tem go, gopls, etc no PATH, sem instalar no SO
```

Em Go seria equivalente a um `docker run -it -v $PWD:/app golang:1.21 bash` — mas nativo, sem container.

---

## Exemplo 3: como um input chega num módulo (seu caso real)

No seu `mineserver_forge.nix`:

```nix
{ inputs, pkgs, lib, ... }:   # ← 'inputs' chega aqui porque specialArgs injetou

{
  imports = [ inputs.nix-minecraft.nixosModules.minecraft-servers ];
  nixpkgs.overlays = [ inputs.nix-minecraft.overlay ];
  ...
}
```

Fluxo:
1. `flake.nix` declara `inputs.nix-minecraft`.
2. `specialArgs = { inherit inputs; }` repassa p/ todos os módulos.
3. `mineserver_forge.nix` recebe `inputs` como parâmetro da função.
4. Usa `inputs.nix-minecraft.nixosModules.minecraft-servers` (o módulo NixOS que o repo externo expõe como output).

Em Go seria: você importa um package externo (`github.com/Infinidoge/nix-minecraft`), e ele expõe símbolos públicos (`nixosModules.minecraft-servers` é tipo uma `var MinecraftServersModule = ...` exportada).

---

## `flake.lock` — o `go.sum`

```json
"nix-minecraft": {
  "locked": {
    "lastModified": 1782360767,
    "narHash": "sha256-KFsLn544BrDrBI1jsT/XtWxlfs2oTCrJZ77XxUxZS6I=",
    "rev": "7e4eb48f80c90dab1ea331c43eb332b47e4cc59e"
  }
}
```

- Cada input é travado por **rev** (commit hash) + **narHash** (hash do conteúdo).
- `narHash` = equivalente a `sha256` de um tarball; garante que o `rev` não foi maliciosamente substituído.
- Atualizar: `nix flake update` (atualiza tudo) ou `nix flake update --impure` ou input específico.
- **Commitar o `flake.lock`** sempre — é o que garante reprodutibilidade (`go.sum` também é commitado).

---

## Comandos essenciais (analogia Go)

| Ação | Go | Flake |
|---|---|---|
| Buildar | `go build ./...` | `nix build` |
| Rodar sem instalar | `go run .` | `nix run .#default` |
| Instalar no perfil | `go install` | `nix profile install .#default` |
| Entrar ambiente dev | `docker run -it golang bash` | `nix develop` |
| Atualizar deps | `go get -u && go mod tidy` | `nix flake update` |
| Ver inputs travados | `cat go.sum` | `nix flake metadata` |
| Ver outputs | `go list ./...` | `nix flake show` |
| Aplicar config SO | (n/a) | `sudo nixos-rebuild switch --flake .#nixos` |

`.#nixos` = "este dir, output `nixosConfigurations.nixos`".

---

## Por que usar flakes? (resumo)

1. **Reprodutibilidade real** — `flake.lock` trava tudo. Outra máquina, outro ano, mesmo resultado.
2. **Sem channels** — você não depende de `nix-channel --update` sincronizar; o input é git rev.
3. **Composabilidade** — inputs podem ser outros flakes (nix-minecraft, sops-nix, home-manager...). Ecossistema.
4. **Auto-contido** — um repo com `flake.nix` é tudo que precisa. Clona, `nix build`, funciona.
5. **Multi-output** — mesmo flake pode oferecer packages, devShells, nixosConfigurations, overlays.

---

## Como adicionar um input novo (workflow)

Exemplo: adicionar `home-manager`.

```nix
inputs = {
  nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  home-manager = {
    url = "github:nix-community/home-manager";
    inputs.nixpkgs.follows = "nixpkgs";  # reusa seu nixpkgs
  };
};
```

Depois no output:
```nix
modules = [
  ./configuration.nix
  inputs.home-manager.nixosModules.home-manager
  {
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
  }
];
```

Rodar `nix flake lock` p/ atualizar `flake.lock` p/ o novo input, depois `sudo nixos-rebuild switch`.

---

## Múltiplos flakes em um projeto

**Sim, SEMPRE.** Um `flake.nix` agrega N flakes externos como `inputs` — cada flake externo expõe seus próprios outputs (`packages`, `devShells`, `lib`, `nixosModules`, `overlays`) que você consome.

### Exemplo: projeto Go + postgres + lint hooks

```nix
{
  description = "App Go com DB e ferramentas de prof";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    gomod2nix = {
      url = "github:nix-community/gomod2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, gomod2nix, pre-commit-hooks }:
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
    in {
      packages.x86_64-linux.default = gomod2nix.default.x86_64-linux.buildGoApplication {
        pname = "app";
        src = ./.;
        modules = ./gomod2nix.toml;
      };
      devShells.x86_64-linux.default = pkgs.mkShell {
        packages = with pkgs; [ go postgresql_16 ];
        inputsFrom = [ pre-commit-hooks.devShell.x86_64-linux ];
      };
      checks.x86_64-linux.pre-commit-check = pre-commit-hooks.lib.x86_64-linux.run {
        src = ./.;
        hooks.gofmt.enable = true;
      };
    };
}
```

### Múltiplos flakes no `configuration.nix`

Você **já faz isso**. Seu `flake.nix` tem `nix-minecraft` e `nixpkgs`. Cada flake externo vira um `input`, expõe módulos que você importa:

```nix
# flake.nix
specialArgs = { inherit inputs; };
modules = [
  ./configuration.nix
  inputs.nix-minecraft.nixosModules.minecraft-servers
  inputs.sops-nix.nixosModules.sops
  inputs.home-manager.nixosModules.home-manager
];
```

Para acessar inputs **dentro** de `configuration.nix` (hoje não acessa), adicione à assinatura:

```nix
# configuration.nix
{ config, pkgs, lib, inputs, ... }:  # ← 'inputs' agora disponível
```

Sem `inputs` na assinatura, `configuration.nix` não "vê" as flakes externas (só `mineserver_forge.nix` vê porque já declara `{ inputs, ... }`).

---

## TL;DR

- Flake = `go.mod`/`go.sum` para Nix.
- `inputs` = dependências travadas por git rev + hash.
- `outputs` = função `inputs → { packages, devShells, nixosConfigurations, ... }`.
- `specialArgs` injeta inputs nos módulos (igual middleware args).
- `follows` evita duplicates do nixpkgs (igual `replace` em go.mod).
- `flake.lock` é commitado, garante reprodutibilidade.
- `nixos-rebuild switch --flake .#nixos` aplica.
- **Múltiplos flakes**: um `flake.nix` com N `inputs`. Cada input expõe outputs que você consome.
- **No `configuration.nix`**: declare `{ inputs, ... }` na assinatura p/ acessar.
