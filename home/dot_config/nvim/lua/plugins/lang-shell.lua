-- lang-shell.lua — suporte a Bash/shell script, que a LazyVim NÃO cobre com um "extra"
-- oficial (só existe extras/lang pra typescript/tailwind/json/yaml/markdown/python/docker/
-- omnisharp — conferido na doc oficial, doc 03). Relevante aqui porque o setup inteiro é
-- recheado de shell script (run_after_*.sh do chezmoi, bootstrap.sh do doc 06, scripts do
-- Quickshell) — vale o mesmo nível de suporte (LSP + lint + format) que as outras linguagens.
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        bashls = {},
      },
    },
  },
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "bash-language-server", "shellcheck", "shfmt" })
    end,
  },
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        sh = { "shfmt" },
        bash = { "shfmt" },
      },
    },
  },
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = {
        sh = { "shellcheck" },
        bash = { "shellcheck" },
      },
    },
  },
}
