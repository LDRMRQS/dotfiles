-- pkm-obsidian.lua — PKM/journal dentro do Neovim (doc 05, segundo item em aberto).
--
-- Decisão: obsidian.nvim, standalone — sem precisar do app Obsidian instalado. Funciona em cima
-- de markdown puro (não inventa formato proprietário), então o "vault" aqui é só uma pasta comum
-- que também dá pra abrir com qualquer outro editor/sincronizar como qualquer outra pasta.
--
-- Por que isso e não uma solução mais simples (ex: só uma pasta de .md solta, sem plugin): o
-- ganho concreto é daily notes com template automático, backlinks/busca entre notas, e completar
-- `[[wikilinks]]` — que é exatamente o que o doc 05 pedia ("virar Neovim num PKM/journal"), sem
-- exigir aprender uma sintaxe nova além de markdown.
--
-- Vault único, local, sem sync na nuvem por enquanto (fora de escopo do doc 05 — se precisar
-- sincronizar entre máquinas no futuro, é a mesma pasta podendo entrar num repo git separado do
-- dotfiles, não faz sentido misturar notas pessoais dentro do repo de configuração).
return {
  {
    "epwalsh/obsidian.nvim",
    version = "*",
    lazy = true,
    ft = "markdown",
    -- carrega também ao abrir a pasta do vault direto, não só arquivos .md dentro dela
    event = {
      "BufReadPre " .. vim.fn.expand("~") .. "/vault/**.md",
      "BufNewFile " .. vim.fn.expand("~") .. "/vault/**.md",
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    opts = {
      workspaces = {
        {
          name = "vault",
          path = "~/vault",
        },
      },
      -- doc 05: journal/daily notes é o caso de uso central pedido
      daily_notes = {
        folder = "daily",
        date_format = "%Y-%m-%d",
        template = nil, -- sem template de arquivo por enquanto; texto inicial default do plugin basta
      },
      completion = {
        nvim_cmp = false, -- LazyVim usa blink.cmp por padrão, não nvim-cmp (ver doc 03)
        blink = true,
      },
      -- desliga a UI "estilizada" (conceal de checkbox/heading) pra não brigar visualmente com o
      -- tema aether.nvim (doc 07) — fica just markdown normal, sem reinterpretar símbolo
      ui = { enable = false },
    },
    keys = {
      { "<leader>on", "<cmd>ObsidianNew<cr>", desc = "PKM: nova nota" },
      { "<leader>oo", "<cmd>ObsidianQuickSwitch<cr>", desc = "PKM: abrir nota" },
      { "<leader>od", "<cmd>ObsidianToday<cr>", desc = "PKM: daily note de hoje" },
      { "<leader>os", "<cmd>ObsidianSearch<cr>", desc = "PKM: buscar no vault" },
      { "<leader>ob", "<cmd>ObsidianBacklinks<cr>", desc = "PKM: backlinks da nota atual" },
    },
  },
}
