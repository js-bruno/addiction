# Flake - Ideias de projetos para treinar

8 projetos graduais — do mais fácil ao mais complexo. Cada um ensina um conceito diferente e pode ser completado em 30 min a 2 h.

---

## Nível 1: Zero flake → pacote básico

**Objetivo**: Criar um flake do zero, buildar e rodar.

**Projeto**: Empacote um script bash que imprime "hello flake" com data.

```bash
mkdir hello-flake && cd hello-flake && git init
cat > hello.sh <<'EOF'
#!/usr/bin/env bash
echo "hello flake at $(date)"
EOF
chmod +x hello.sh
```

Escreva `flake.nix` que copia `hello.sh` para `$out/bin/hello`.

**O que aprende:**
- `stdenv.mkDerivation`
- `nix build` / `nix run`
- `result/` symlink

---

## Nível 2: DevShell para projeto Go

### Objetivo: Configurar ambiente de dev reproduzível.

**Projeto**: Crie um flake com `devShells` que exponha Go 1.24, gopls, e um script de ativação.

```bash
mkdir go-devshell && git init
# Escreva flake.nix com devShells
nix develop
```

**Extensão**: Adicione Docker + Postgres (pra testar `nix develop -c scripts/test.sh`).

**O que aprende:**
- `devShells`
- `mkShell`, `shellHook`
- Repositórios de toolchain

---

## Nível 3: Processar arquivos (parse de JSON/YAML)

### Objetivo: Script utilitário que processa dados com Nix.

**Projeto**: Crie um programa que lê um "banco" JSON: `{users: [{nome, idade}]}` e imprime "Acima de 18: NOME" em ordem alfabética. O processamento todo é Nix (não shell).

```nix
# flake.nix
packages = {
  process = pkgs.writeShellScriptBin "process-users" ''
    ${pkgs.nix}/bin/nix-instantiate --eval --expr "
      let users = builtins.fromJSON (builtins.readFile ./users.json);
      in builtins.concatStringsSep \"\n\" ...users
    "
  '';
};
```

**O que aprende:**
- `builtins.fromJSON`, `builtins.readFile`
- `writeShellScriptBin`, `writeTextFile`
- Processamento puro em Nix

---

## Nível 4: Empacotar um app Go (seu!)

### Objetivo: Usar `buildGoModule` para empacotar app Go próprio

**Projeto**: Crie um mini CLI em Go: `nix-counter` que lê um int e conta inverso até zero, depois corta e imprime.

Repo:
```
nix-counter/
  flake.nix
  main.go
  go.mod
  go.sum
```

Depois: `nix run github:seunick/nix-counter -- 5`

**O que aprende:**
- `buildGoModule`
- Vendor hash
- Outputs multi-siolade

---

## Nível 5: Composição de dois flakes (só de treino)

### Objetivo: Demonstrar mútliplos inputs.

**Projeto**: Crie um flake para uma app Go, outro para uma lib que a app consome (exporta função). O flake principal dá o app e depois importa `buildInputs` do da lib.

```
app-flake/          # flake principal (golibapp)
lib-flake/          # exporta a função "sau" "fmt.Printf"
```

**O que aprende:**
- Múltiplos inputs
- `buildInputs` entre flakes
- Como expor libs exportáveis

---

## Nível 6: Docker image declarativa

### Objetivo: Gerar imagem Docker com Nix.

**Projeto**: Crie um flake que usa `dockerTools.buildLayeredImage` para empacotar um app Go dentro de uma imagem mínima.

```bash
nix build .#dockerImage
docker load < result   # (a ferramente .tar.gz)
docker run -t PRJ_NAME:latest
```

**O que apende:**
- `dockertools.buildImage/buildLayeredImage`
- Reduzir tamanho de imagem (pode ser 90% menor que Dockerfile)
- `config.Cmd`, `contents`, `config.Env`

---

## Nível 7: Template flake

### Objetivo: Tornar seu projeto um template instanciável.

**Projeto**: Crie um repo que exponha `templates.go` com:

- `devShells` Go
- LICENSE
- .gitignore, .env
- `.golangci-lint.yml` (ou equivalente em TS/Python)

```nix
templates = {
  go = {
    path = ./templates/go;
    description = "Go project with flakes";
  };
  py = {
    path = ./templates/py;
    description = "Python project";
  };
};
```

Outra pessoa roda: `nix flake init -t github:seunick/templates#go`.

**O que aprende:**
- `templates` output
- Estruturando templates
- `nix flake show`

---

## Nível 8: Mini-SO NixOS complementar

### Objetivo: NixOS minimal com `nixosConfigurations` de treino

Crie um repositório separado que:

- Declara um SO mínimo (jellyfin, samba)
- Inclui módulo `./configuration.nix` puro (sem flake do seu host real)
- Pode ser usado com `nixos-generators` para criar ISO ou VM virtual da imagem

Apenas execução externa, não substituição do seu SO real — teste em QEMU/Container.

OBa:

```bash
nix build .#nixosConfigurations.test.config.system.build.toplevel  # ISO ou disco
```

**O que aprenda:**
- `nixpkgs.lib.nixosSystem`
- `system.build.t
- Dockerized Nix (ou ISO) para seed de SO

---

## Tabela de aprendizado diagonal

| Nível | Projeto | Conceitos aprendidos |
|---|---|---|
| 1 | Zero→flake | `mkDerivation`, `nix build`/`run` |
| 2 | devShell | `mkShell`, `shellHook`, env automático |
| 3 | Processador JSON | `builtins`, Nix como linguagem pura |
| 4 | App Go empacotado | `buildGoModule`, vendor hash |
| 5 | Dois flakes combinados | `inputs` + `follows`, `buildInputs` inter-flake |
| 6 | Docker declarativo | `dockerTools`, container minúsculo |
| 7 | Templates custom | `templates.go`, `nix flake init -t` |
| 8 | SO complementar | `nixosConfigurations`, módulos, `specialArgs` |

---

## Regra de game-loop python

1. Escrever `flake.nix` + arquivos.
2. `git add -A` (flake NÃO roda sem os arquivos comitados!).
3. `nix build .#default` → se der erro, ajustar.
4. `nix run .#default` → testar resultado.

Para todos projetos que envolvem Go: **1** tempo inicial inclui gerar `vendorHash` ou escrever `vendorHash = null` e depois `nix build; nix hash to-sri ... "`.

Jamais esqueça: **`git add` antes de build**.