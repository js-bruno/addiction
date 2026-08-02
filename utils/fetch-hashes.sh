#!/usr/bin/env bash
# fetch-hashes.sh
#
# Roda o nix-modrinth-prefetch para cada mod e imprime o bloco fetchurl
# pronto para colar no minecraft-server.nix.
#
# Uso: bash fetch-hashes.sh
# Requer: nix (flakes habilitados)

set -euo pipefail

RUNNER="nix run github:Infinidoge/nix-minecraft#nix-modrinth-prefetch --"

echo "================================================================"
echo "  Buscando hashes dos mods — NeoForge 1.21.4"
echo "================================================================"
echo ""

# Formato: "NOME|VERSION_ID|DESCRIÇÃO"
# Para encontrar o VERSION_ID de um mod:
#   1. Vá em modrinth.com/mod/<slug>/versions
#   2. Filtre por NeoForge + 1.21.4
#   3. Clique na versão desejada → copie o "Version ID" exibido na página

MODS=(
  "FerriteCore 7.1.2|gTYCIFFQ|Redução de uso de RAM"
  "ModernFix 5.20.3 NeoForge|KO2YAGYg|Startup rápido e correções"
)

# Mods cujo VERSION_ID você precisa buscar manualmente em modrinth.com:
MODS_PENDENTES=(
  "ServerCore|modrinth.com/mod/servercore/versions?g=1.21.4&l=neoforge"
  "Clumps|modrinth.com/mod/clumps/versions?g=1.21.4&l=neoforge"
  "Waystones|modrinth.com/mod/waystones/versions?g=1.21.4&l=neoforge"
  "JEI|modrinth.com/mod/jei/versions?g=1.21.4&l=neoforge"
)

for entry in "${MODS[@]}"; do
  IFS="|" read -r nome version_id descricao <<< "$entry"
  echo "──────────────────────────────────────────"
  echo "  Mod: $nome"
  echo "  Desc: $descricao"
  echo "  Version ID: $version_id"
  echo ""
  $RUNNER "$version_id" 2>/dev/null || echo "  [ERRO] Falha ao buscar $nome"
  echo ""
done

echo "================================================================"
echo "  Mods com VERSION_ID pendente — busque manualmente:"
echo "================================================================"
for entry in "${MODS_PENDENTES[@]}"; do
  IFS="|" read -r nome url <<< "$entry"
  echo ""
  echo "  Mod: $nome"
  echo "  Página: https://$url"
  echo "  Após copiar o Version ID, rode:"
  echo "    $RUNNER <VERSION_ID>"
done

echo ""
echo "================================================================"
echo "  Após obter todos os hashes, substitua lib.fakeHash em"
echo "  minecraft-server.nix pelo hash sha512 correspondente."
echo "================================================================"
