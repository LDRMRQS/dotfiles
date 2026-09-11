# arch-ricing — dotfiles

Ambiente Arch Linux completo (Hyprland + Quickshell + SDDM), com tema fixo próprio (mashup
[omarchy-brutalism-theme](https://github.com/bjornramberg/omarchy-brutalism-theme) +
[omarchy-nes-theme](https://github.com/bjarneo/omarchy-nes-theme)) propagado por uma única fonte
de cores (`home/.chezmoidata/colors.yaml`) via [chezmoi](https://www.chezmoi.io/).

O racional completo de cada decisão (por que chezmoi, por que essa paleta, por que essa
distribuição do Neovim, etc.) está documentado no projeto Claude que acompanhou a montagem desse
repo — este README é só o guia prático de uso.

## Instalação numa máquina nova (Arch já instalado, LUKS2/Btrfs já particionado)

```sh
git clone git@github.com:<seu-usuario>/dotfiles.git
cd dotfiles
./bootstrap.sh
```

O `bootstrap.sh` instala os pacotes oficiais + AUR (via `paru`, compilado na hora se não
existir), copia os arquivos de sistema (`system/`) pros lugares certos com `sudo`, habilita os
serviços necessários e por fim roda `chezmoi init --apply` apontando pro próprio clone local.

**Pré-requisitos que o script pressupõe já prontos** (não são dele): disco particionado com
LUKS2 + TPM2 + Btrfs, rede funcionando, e a chave privada `age`
(`~/.config/chezmoi/key.txt`) restaurada de um backup seguro — sem ela o `chezmoi apply` não
decifra os secrets do repo.

## Estrutura

```
dotfiles/
├── home/              → gerenciado pelo chezmoi (aponta pro $HOME)
│   ├── dot_config/
│   │   ├── hypr/            Hyprland + hyprlock + hypridle + hyprpaper
│   │   ├── quickshell/      barra/dashboard/launcher/menu de sessão em QML
│   │   ├── kitty/
│   │   ├── fish/
│   │   ├── tmux/
│   │   ├── nvim/            LazyVim + aether.nvim (colorscheme na paleta do projeto) +
│   │   │                    IA local (codecompanion.nvim/Ollama) + PKM (obsidian.nvim)
│   │   ├── starship.toml.tmpl
│   │   ├── gtk-3.0/ gtk-4.0/
│   │   └── backgrounds/     wallpapers versionados (leves, ~1.3MB no total)
│   ├── dot_local/share/sddm-themes/arch-ricing/   tema SDDM próprio
│   ├── .chezmoidata/colors.yaml   fonte única de cor pra tudo isso
│   ├── .chezmoi.toml.tmpl         config do chezmoi (chave pública age)
│   └── run_after_10-sync-sddm-theme.sh   hook: sincroniza o tema SDDM renderizado pro caminho de sistema
├── system/            → arquivos de referência, aplicados por bootstrap.sh (fora do alcance do chezmoi)
│   ├── pacman.conf.d/cachyos.conf   documentação do que o instalador oficial do CachyOS gera
│   ├── mkinitcpio.conf              hooks LUKS2+TPM2+Btrfs
│   ├── sddm.conf.d/theme.conf       seleciona qual tema o SDDM usa
│   ├── libvirt/                     referência de config da VM Windows (virtiofs)
│   └── ufw-rules.sh                 política de firewall
├── bootstrap.sh
└── README.md
```

## Uso do dia a dia

- **Editar uma config**: `chezmoi edit ~/.config/hypr/hyprland.conf` → `chezmoi apply` → commit/push dentro do source dir (`chezmoi cd`).
- **Trocar a paleta inteira**: editar `home/.chezmoidata/colors.yaml`, rodar `chezmoi apply` — propaga pra Hyprland, Quickshell, kitty, GTK, SDDM, Neovim e tmux/starship de uma vez, sem caçar cor arquivo por arquivo.
- **Puxar mudança de outra máquina**: `chezmoi update`.
- **Segredo novo** (token, API key): `chezmoi add --encrypt <arquivo>`.

## Nota sobre o bit de execução

`bootstrap.sh`, `system/ufw-rules.sh` e `home/run_after_10-sync-sddm-theme.sh` precisam estar
marcados como executáveis (`chmod +x`) **antes do primeiro commit** — sem isso o chezmoi não
reconhece o hook do SDDM como executável, e rodar os outros dois exige `bash arquivo.sh` toda vez
em vez de `./arquivo.sh`. Se você recebeu este repositório como um `.tar.gz`, os bits já vêm
corretos (tar preserva permissão); se copiou os arquivos por outro meio, rode:

```sh
chmod +x bootstrap.sh system/ufw-rules.sh home/run_after_10-sync-sddm-theme.sh
```
