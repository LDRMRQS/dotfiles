#!/usr/bin/env bash
# run_after_10-sync-sddm-theme.sh — hook do chezmoi (roda automaticamente depois de todo
# `chezmoi apply`). Existe por causa de uma limitação real: o tema SDDM vive em
# home/dot_local/share/sddm-themes/arch-ricing/ pra poder ser templated com o colors.yaml
# (mesma fonte única de cor de todo o resto — ver doc 07), mas o SDDM só lê temas de
# /usr/share/sddm/themes/ — fora do $HOME, e o diretório home normalmente é 700 (sem
# permissão de leitura pro usuário de sistema `sddm`). Ou seja: sem esse passo, o
# `chezmoi apply` renderiza o QML certinho, mas o SDDM nunca vê a versão nova.
#
# Sem isso precisar virar um passo manual toda vez que a paleta mudar, o chezmoi já roda
# esse hook sozinho a cada apply — o `cp` é idempotente e barato o suficiente pra rodar
# sempre, mesmo quando nada mudou de fato.
set -euo pipefail

SRC="$HOME/.local/share/sddm-themes/arch-ricing"
DST="/usr/share/sddm/themes/arch-ricing"

if [ ! -d "$SRC" ]; then
    echo "run_after_10-sync-sddm-theme: $SRC não existe, pulando." >&2
    exit 0
fi

sudo mkdir -p "$DST"
sudo cp -r "$SRC/." "$DST/"
echo "Tema SDDM sincronizado em $DST"
