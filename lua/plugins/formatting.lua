return {
  {
    "stevearc/conform.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local conform = require("conform")

      ---@param bufnr integer
      ---@param ... string
      ---@return string
      local function first(bufnr, ...)
        for i = 1, select("#", ...) do
          local formatter = select(i, ...)
          if conform.get_formatter_info(formatter, bufnr).available then
            return formatter
          end
        end
        return select(1, ...)
      end

      local firstPrettier = function(bufnr)
        return { first(bufnr, "prettierd", "prettier"), "injected" }
      end

      conform.setup({
        format_on_save = {
          timeout_ms = 1500,
          lsp_format = "fallback"
        },
        formatters_by_ft = {
          css = firstPrettier,
          graphql = firstPrettier,
          html = firstPrettier,
          javascript = firstPrettier,
          javascriptreact = firstPrettier,
          json = firstPrettier,
          lua = { "stylua" },
          markdown = firstPrettier,
          python = { "isort", "black" },
          ruby = { "standardrb" },
          sql = { "sql-formatter" },
          swift = { "swift_format" },
          svelte = firstPrettier,
          typescript = firstPrettier,
          typescriptreact = firstPrettier,
          yaml = firstPrettier,
          xml = { "xmlformatter" }
        },
      })

      vim.keymap.set({ "n" }, "<leader>f", function()
        conform.format({
          lsp_fallback = true,
          async = true,
          --timeout_ms = 1500,
        })
      end, { desc = "format file" })

      vim.keymap.set({ "v" }, "<leader>f", function()
        conform.format({
          lsp_fallback = true,
          async = true,
          --timeout_ms = 1500,
        })
      end, { desc = "format selection" })

      vim.api.nvim_create_user_command("Format", function(args)
        local range = nil
        if args.count ~= -1 then
          local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
          range = {
            start = { args.line1, 0 },
            ["end"] = { args.line2, end_line:len() },
          }
        end

        conform.format({ async = true, lsp_fallback = true, range = range })
      end, { range = true })
    end,
  },
}
