-- keymaps.lua — carregado no evento VeryLazy (doc 03).
-- Defaults completos da LazyVim: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
--
-- NOTA HONESTA: o doc 07 registra que os keymaps do `keymaps.lua` da config antiga (LDRConfig)
-- eram "genéricos e bons... aproveita 100%", citando três comportamentos (clipboard do sistema,
-- mover linha, centralizar scroll ao buscar). O arquivo original em si não sobreviveu no
-- contexto desta sessão (só o resumo ficou) — o que está abaixo é uma RECONSTRUÇÃO desses três
-- comportamentos com os bindings padrão de mercado pra cada um, não um port literal do arquivo
-- antigo. Se o `keymaps.lua` original ainda existir em algum backup, vale colar o conteúdo real
-- aqui por cima disso.

local map = vim.keymap.set

-- Clipboard do sistema — yank/paste/delete usando o registro "+ por padrão em vez do registro
-- sem nome, pra não precisar lembrar de prefixar "+ toda hora (comportamento citado no doc 07).
map({ "n", "v" }, "<leader>y", [["+y]], { desc = "Yank pro clipboard do sistema" })
map("n", "<leader>Y", [["+Y]], { desc = "Yank da linha pro clipboard do sistema" })
map({ "n", "v" }, "<leader>p", [["+p]], { desc = "Paste do clipboard do sistema" })
map({ "n", "v" }, "<leader>P", [["+P]], { desc = "Paste (antes) do clipboard do sistema" })

-- Mover linha(s) selecionada(s) pra cima/baixo com Alt+j/k, em normal e visual.
map("n", "<A-j>", "<cmd>m .+1<CR>==", { desc = "Mover linha pra baixo" })
map("n", "<A-k>", "<cmd>m .-2<CR>==", { desc = "Mover linha pra cima" })
map("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Mover seleção pra baixo" })
map("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Mover seleção pra cima" })

-- Centralizar a tela ao navegar em busca/scroll — evita o texto encontrado ficar colado na
-- borda da tela (comportamento citado no doc 07).
map("n", "n", "nzzzv", { desc = "Próxima ocorrência (centralizada)" })
map("n", "N", "Nzzzv", { desc = "Ocorrência anterior (centralizada)" })
map("n", "<C-d>", "<C-d>zz", { desc = "Meia página pra baixo (centralizada)" })
map("n", "<C-u>", "<C-u>zz", { desc = "Meia página pra cima (centralizada)" })
