-- lazy.lua — bootstrap do lazy.nvim + spec principal da LazyVim (doc 03).
-- Estrutura padrão do template oficial da LazyVim (LazyVim/starter), sem reinventar o
-- bootstrap: clona o lazy.nvim na primeira execução, depois só carrega normal.
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = {
    -- LazyVim em si (LSP/treesitter/telescope/mason/UI, tudo "de fábrica")
    { "LazyVim/LazyVim", import = "lazyvim.plugins" },

    -- Extras de linguagem — mapeados 1:1 no stack do doc 03, nada além do que já decidimos
    -- instalar de verdade (evita puxar LSP/formatter de uma stack que não existe aqui):
    { import = "lazyvim.plugins.extras.lang.typescript" }, -- Next.js/TS (doc 03)
    { import = "lazyvim.plugins.extras.lang.tailwind" },   -- Tailwind (doc 03)
    { import = "lazyvim.plugins.extras.lang.json" },       -- package.json, tsconfig, etc.
    { import = "lazyvim.plugins.extras.lang.yaml" },       -- docker-compose, CI, e o próprio
                                                            -- colors.yaml/chezmoidata (doc 07)
    { import = "lazyvim.plugins.extras.lang.markdown" },   -- os próprios docs do projeto (claude/*.md)
    { import = "lazyvim.plugins.extras.lang.python" },     -- Python via uv (doc 03) — extra já
                                                            -- vem com pyright+ruff, cobre o uv
                                                            -- sem precisar reconfigurar nada
    { import = "lazyvim.plugins.extras.lang.docker" },     -- Dockerfile/compose (doc 03)
    { import = "lazyvim.plugins.extras.lang.omnisharp" },  -- .NET/C# (doc 03) — **decisão**:
    -- OmniSharp em vez de csharp-ls (a dúvida que ficava aberta no doc 03): é o extra oficial
    -- da LazyVim, com integração completa (omnisharp-extended-lsp pra go-to-definition,
    -- neotest-dotnet, netcoredbg via mason) — csharp-ls não tem extra oficial equivalente,
    -- teria que ser montado na mão sem o mesmo nível de suporte.

    -- Nosso override de colorscheme (aether.nvim + colors.yaml, ver doc 07) e os plugins
    -- extras que a LazyVim não cobre (lang-shell.lua, treesitter.lua) — ver lua/plugins/.
    { import = "plugins" },
  },
  defaults = {
    lazy = false,
    version = false, -- sempre a última tag de cada plugin (mesma filosofia do resto do
                      -- setup: sem pin manual de versão espalhado por 20 arquivos)
  },
  install = { colorscheme = { "aether", "habamax" } }, -- aether = nosso tema (doc 07);
  -- habamax só como fallback de emergência se o aether.nvim falhar ao instalar na primeira vez
  checker = { enabled = true },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})
