# config.fish — gerenciado pelo chezmoi (doc 03/06). Não referencia colors.yaml (fish em si não
# tem "tema de cor" próprio pra shell — só o que o terminal/kitty já define, ver kitty.conf.tmpl),
# então fica como arquivo estático, sem `.tmpl` (mesmo princípio do hyprpaper.conf/hypridle.conf,
# ver doc 07: só vira `.tmpl` quando referencia de fato uma cor do colors.yaml).
# NÃO editar o arquivo final direto (~/.config/fish/config.fish) — editar este arquivo aqui no
# repo e rodar `chezmoi apply`.

if status is-interactive
    # fish já vem com autosuggestion/syntax highlighting de fábrica (doc 03) — não precisa de
    # framework tipo oh-my-fish/fisher pra isso.
    set -g fish_greeting

    # Prompt — starship.toml.tmpl (doc 07), estilo Omarchy simplificado
    starship init fish | source

    # zoxide — substituto inteligente do cd (doc 03): `z` navega pelo histórico de diretórios
    zoxide init fish | source

    # fnm — gerenciador de versão do Node (doc 03), troca de versão automática via .node-version
    fnm env --use-on-cd | source

    # uv — gerenciador Python (doc 03) não precisa de hook de shell, funciona via comando direto

    # --- Aliases pros utilitários modernos que substituem os clássicos (doc 03) ---
    alias ls='eza --icons --group-directories-first'
    alias ll='eza -l --icons --group-directories-first'
    alias la='eza -la --icons --group-directories-first'
    alias tree='eza --tree --icons'
    alias cat='bat --paging=never'
    alias grep='rg'
    alias find='fd'

    # Git / dev — atalhos curtos pros binários já decididos (doc 03)
    alias lg='lazygit'
    alias gs='git status'
    alias gd='git diff'

    # fzf — key bindings padrão (Ctrl+R histórico, Ctrl+T arquivo, Alt+C diretório). Usa os
    # scripts que o próprio pacote `fzf` do Arch instala em /usr/share/fzf/ (mais garantido do
    # que `fzf --fish | source`, que depende da versão do fzf ter esse flag).
    if test -f /usr/share/fzf/key-bindings.fish
        source /usr/share/fzf/key-bindings.fish
    end
    if test -f /usr/share/fzf/completion.fish
        source /usr/share/fzf/completion.fish
    end
end
