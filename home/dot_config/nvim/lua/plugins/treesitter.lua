-- treesitter.lua — parsers extras que nenhum dos "lang extras" da LazyVim já traz de bônus,
-- mas que aparecem direto nos arquivos deste próprio repo de dotfiles (doc 06/07): bash (ver
-- lang-shell.lua), toml (Cargo.toml/pyproject.toml eventuais) e QML (Quickshell/SDDM, doc 07)
-- — QML não tem parser dedicado no nvim-treesitter ainda, então cai em javascript/qmljs via
-- filetype (mantido comentado até confirmar suporte real, pra não quebrar install na primeira
-- rodada).
return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "bash", "toml" })
    end,
  },
}
