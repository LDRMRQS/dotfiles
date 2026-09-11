-- ai-codecompanion.lua — IA local no Neovim (doc 05), complementando o Claude Code CLI (doc 03)
-- pra tarefas rápidas/offline/sensíveis, sem gastar chamada de API externa.
--
-- Decisão (doc 05 tinha 3 candidatos em aberto: codecompanion.nvim / avante.nvim / gen.nvim):
-- **codecompanion.nvim**. Motivo: `avante.nvim` mira recriar uma experiência tipo Cursor
-- (aplicar diff, agente que edita arquivo sozinho) — isso já é literalmente o papel do Claude
-- Code CLI aqui (doc 03), então ganharíamos uma segunda ferramenta fazendo a mesma coisa em vez
-- de complementar. `gen.nvim` é simples demais pro outro lado (só substitui texto selecionado
-- por um prompt, sem chat com contexto/histórico) — não serve bem pra "conversar sobre um
-- trecho de dado sensível" (um dos 3 casos de uso do doc 05). `codecompanion.nvim` fica no meio:
-- chat com histórico + ações inline (explicar/refatorar trecho selecionado) + adapter nativo
-- pro Ollama, sem tentar ser um segundo agente autônomo.
--
-- Adapter: `ollama`, apontando pro servidor local (doc 05: `ollama.service` já roda em
-- localhost:11434 por padrão, sem precisar mudar nada na config do Ollama em si).
--
-- ⚠️ MODELO: doc 05 registra o "Bonsai" (27B, quantização ternária ~4GB) como modelo pretendido,
-- mas com uma pendência real ainda não resolvida: não está confirmado se o Ollama consegue
-- baixar/rodar esse formato ternário nativamente (pode exigir `bitnet.cpp` como runtime
-- separado — ver doc 05). Por isso o `model` abaixo fica com um modelo convencional pequeno
-- (`qwen2.5-coder:7b`, formato GGUF Q4 padrão do Ollama, roda bem em CPU no i5-12450H) como
-- fallback funcional imediato — trocar pelo nome real do Bonsai assim que a pendência do doc 05
-- for resolvida (`ollama list` depois de confirmar como ele foi baixado).
return {
  {
    "olimorris/codecompanion.nvim",
    cmd = { "CodeCompanion", "CodeCompanionChat", "CodeCompanionActions" },
    keys = {
      { "<leader>ai", "<cmd>CodeCompanionChat Toggle<cr>", desc = "IA local: chat" },
      { "<leader>aa", "<cmd>CodeCompanionActions<cr>", mode = { "n", "v" }, desc = "IA local: ações" },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    opts = {
      adapters = {
        ollama = function()
          return require("codecompanion.adapters").extend("ollama", {
            url = "http://localhost:11434",
            schema = {
              model = {
                default = "qwen2.5-coder:7b", -- ⚠️ trocar pelo Bonsai quando a pendência do doc 05 fechar
              },
            },
          })
        end,
      },
      strategies = {
        chat = { adapter = "ollama" },
        inline = { adapter = "ollama" },
      },
    },
  },
}
