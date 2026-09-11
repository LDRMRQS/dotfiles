#!/usr/bin/env bash
# bootstrap.sh — script único de instalação num notebook Arch novo/formatado (doc 06).
# NÃO é algo "vivo" como o chezmoi: roda uma vez ao configurar a máquina do zero. Pressupõe que
# o Arch base + LUKS2/Btrfs (doc 01/04) + rede já estão prontos (esse script cuida do que vem
# DEPOIS disso: pacotes, arquivos de sistema, dotfiles).
#
# ⚠️ AVISO HONESTO (herdado dos docs 01/02): vários itens abaixo foram anotados como "não
# consegui validar ao vivo" nos documentos de origem, porque a busca web falhou durante o
# planejamento. Estão marcados com ⚠️ inline. Revisar contra o Arch Wiki / AUR / wiki do CachyOS
# no dia real da instalação antes de rodar — não rodar isso cegamente num sistema de verdade
# sem essa revisão.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> bootstrap.sh — instalação do zero (doc 06)"

# ---------------------------------------------------------------------------
# 1. Repositório CachyOS (doc 02) — via instalador OFICIAL deles, não hardcoded aqui
# ---------------------------------------------------------------------------
echo "==> 1/7 — Repositório CachyOS"
echo "    ⚠️  Confirmar o passo exato em https://wiki.cachyos.org antes de rodar (doc 02)."
echo "    Ver system/pacman.conf.d/cachyos.conf pra referência do que o instalador deve gerar."
read -rp "    Já rodou o instalador oficial do CachyOS nesta máquina? [s/N] " cachyos_done
if [[ "${cachyos_done,,}" != "s" ]]; then
    echo "    Pare aqui, rode o instalador oficial do CachyOS e execute este script de novo."
    exit 1
fi

# ---------------------------------------------------------------------------
# 2. Pacotes oficiais (repos Arch + CachyOS) — consolidado dos docs 01-05/07
# ---------------------------------------------------------------------------
echo "==> 2/7 — Pacotes oficiais (pacman)"

PACMAN_PACKAGES=(
    # Kernel / microcode (doc 02)
    linux-cachyos-lts linux-cachyos-lts-headers intel-ucode
    # Btrfs / snapshots (doc 01)
    btrfs-progs snapper snap-pac
    # Base do sistema (doc 02)
    networkmanager bluez bluez-utils
    pipewire pipewire-alsa pipewire-pulse pipewire-jack wireplumber
    power-profiles-daemon
    hyprpolkitagent
    xdg-desktop-portal-hyprland xdg-desktop-portal-gtk
    noto-fonts ttf-dejavu ttf-jetbrains-mono-nerd
    # Cursor (doc 02/07 — adicionado na revisão geral)
    bibata-cursor-theme
    # Hyprland core (doc 02)
    hyprland hypridle hyprlock hyprpaper wl-clipboard grim slurp
    qt5-wayland qt6-wayland
    # SDDM (doc 02/07)
    sddm
    # Quickshell — deps Qt (doc 02); o Quickshell em si é AUR, ver bloco AUR abaixo
    qt6-declarative qt6-svg qt6-imageformats
    # Ícones (doc 02/07)
    papirus-icon-theme
    # Virtualização (doc 01/02)
    qemu-desktop libvirt virt-manager virtiofsd edk2-ovmf swtpm dnsmasq iptables-nft
    # Descobertas da config antiga (doc 02 §7)
    flatpak thunar brightnessctl playerctl
    # Terminal / shell / dev (doc 03)
    kitty fish starship tmux
    ripgrep fd fzf eza bat zoxide jq
    git github-cli git-delta
    neovim base-devel unzip lua-language-server
    # Python (doc 03)
    python uv
    # .NET (doc 03)
    dotnet-sdk
    # Containers (doc 03)
    docker docker-compose docker-buildx
    # Node.js / Claude Code CLI (doc 03) — nota: se você já rodou os passos manuais do doc 08
    # (instalar Claude Code CLI ANTES do bootstrap, pra ter ele disponível como apoio durante a
    # instalação), node/npm já estão presentes — `--needed` abaixo não reinstala à toa.
    nodejs npm fnm
    # Segurança (doc 04)
    ufw
    # Secrets do chezmoi (doc 06)
    age
    # IA local (doc 05)
    vulkan-intel vulkan-icd-loader vulkan-tools
    # Dotfiles (doc 06)
    chezmoi
)
# ⚠️ Itens acima cuja localização exata (repo oficial Arch vs. CachyOS vs. precisar virar AUR)
# não foi validada ao vivo: `chezmoi`, `ollama` (ver bloco AUR — pode já estar em [extra] em
# versões recentes do Arch, confirmar), `limine`/`limine-snapper-sync` (ver bloco AUR), `fnm`
# (⚠️ pode não estar nos repos oficiais — se `pacman -S fnm` falhar, instalar via
# `curl -fsSL https://fnm.vercel.app/install | bash` como alternativa, doc 03).

sudo pacman -Syu --needed --noconfirm "${PACMAN_PACKAGES[@]}"

# Claude Code CLI (doc 03) — instalado aqui de novo, idempotente, pro caso de este script estar
# rodando numa máquina que NÃO passou pelo passo manual do doc 08 (ex: reaplicar numa segunda
# máquina). Se você já instalou manualmente antes de clonar o repo (fluxo recomendado no doc 08,
# pra ter o Claude Code disponível como apoio durante o resto da instalação), isso é um no-op.
if ! command -v claude &>/dev/null; then
    echo "    Claude Code CLI não encontrado — instalando via npm (doc 03)."
    sudo npm install -g @anthropic-ai/claude-code
fi

# ---------------------------------------------------------------------------
# 3. AUR — via paru (doc 04: helper que mostra o PKGBUILD antes de compilar)
# ---------------------------------------------------------------------------
echo "==> 3/7 — AUR (paru)"
if ! command -v paru &>/dev/null; then
    echo "    paru não encontrado — compilando do AUR (doc 04)."
    tmp_paru="$(mktemp -d)"
    git clone https://aur.archlinux.org/paru.git "$tmp_paru/paru"
    (cd "$tmp_paru/paru" && makepkg -si --noconfirm)
    rm -rf "$tmp_paru"
fi

AUR_PACKAGES=(
    quickshell-git      # Quickshell versão git (doc 02) — Caelestia depende de recursos só nela
    virtio-win           # drivers Windows do virtio, incl. VirtioFS (doc 01)
    limine               # bootloader (doc 01) ⚠️ confirmar se já não está em [extra]
    limine-snapper-sync  # integração Limine + snapper (doc 01)
    pyprland             # scratchpads do Hyprland (doc 02 §7)
    qt6gtk2              # ponte tema Qt6→GTK (doc 02/07)
    qt5-styleplugins     # idem, Qt5 (doc 02/07)
    ollama               # IA local (doc 05) ⚠️ confirmar se já não está em [extra]/[community]
)
# supabase-bin fica de fora de propósito — doc 04 recomenda `npm install -g supabase` em vez do
# pacote AUR `-bin`, pra reduzir uma camada de confiança extra (ver seção "Pacotes AUR" do doc 04).

paru -S --needed --noconfirm "${AUR_PACKAGES[@]}"

# ---------------------------------------------------------------------------
# 4. Grupos de usuário
# ---------------------------------------------------------------------------
echo "==> 4/7 — Grupos de usuário (libvirt, docker)"
sudo usermod -aG libvirt,docker "$USER"
echo "    Você precisa deslogar/logar de novo pra esses grupos terem efeito."

# ---------------------------------------------------------------------------
# 5. Arquivos de sistema (domínio system/ do doc 06 — fora do alcance do chezmoi)
# ---------------------------------------------------------------------------
echo "==> 5/7 — Arquivos de sistema"

echo "    system/mkinitcpio.conf → /etc/mkinitcpio.conf (LUKS2+TPM2+Btrfs, doc 01/04)"
sudo cp "$REPO_DIR/system/mkinitcpio.conf" /etc/mkinitcpio.conf
sudo mkinitcpio -P

echo "    system/sddm.conf.d/theme.conf → /etc/sddm.conf.d/theme.conf (doc 07)"
sudo mkdir -p /etc/sddm.conf.d
sudo cp "$REPO_DIR/system/sddm.conf.d/theme.conf" /etc/sddm.conf.d/theme.conf

echo "    system/pacman.conf.d/cachyos.conf — só referência (ver passo 1), nada a copiar aqui."

echo "    system/libvirt/sharepoint-sync-virtiofs.xml — referência manual pro 'virsh edit' da"
echo "    VM Windows quando ela for criada (doc 01), não copiado automaticamente."

echo "    system/ufw-rules.sh (doc 04)"
bash "$REPO_DIR/system/ufw-rules.sh"

# ---------------------------------------------------------------------------
# 6. Serviços systemd
# ---------------------------------------------------------------------------
echo "==> 6/7 — Habilitando serviços"
sudo systemctl enable --now NetworkManager bluetooth libvirtd docker sddm ollama

# ---------------------------------------------------------------------------
# 7. chezmoi — aplica tudo de home/ (doc 06)
# ---------------------------------------------------------------------------
echo "==> 7/7 — chezmoi"
if [[ ! -f "$HOME/.config/chezmoi/key.txt" ]]; then
    echo "    ⚠️  ~/.config/chezmoi/key.txt (chave privada age) não existe."
    echo "    Gere uma nova com 'age-keygen -o ~/.config/chezmoi/key.txt' OU restaure de um"
    echo "    backup seguro ANTES de continuar — sem ela, o chezmoi não decifra os secrets do"
    echo "    repo (doc 06)."
    exit 1
fi

chezmoi init --apply "$REPO_DIR"

echo "==> Bootstrap concluído. Reinicie a sessão (ou o notebook) pra tudo (grupos, SDDM,"
echo "    Hyprland/Quickshell) entrar em vigor."
