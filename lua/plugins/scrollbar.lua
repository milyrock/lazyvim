return {
  {
    "dstein64/nvim-scrollview",
    event = "LazyFile",
    dependencies = { "lewis6991/gitsigns.nvim" },
    opts = {
      current_only = true,
      mode = "simple",
      visibility = "info",
      character = "│",
      signs_on_startup = {},
      signs_max_per_row_by_group = { gitsigns = 1 },
    },
    config = function(_, opts)
      local function highlights()
        vim.api.nvim_set_hl(0, "ScrollView", { link = "NonText" })
      end
      highlights()
      vim.api.nvim_create_autocmd("ColorScheme", { callback = highlights })
      require("scrollview").setup(opts)
      require("scrollview.contrib.gitsigns").setup({
        add_symbol = "█",
        change_symbol = "█",
        delete_symbol = "█",
        add_highlight = "GitSignsAdd",
        change_highlight = "GitSignsChange",
        delete_highlight = "GitSignsDelete",
        hide_full_add = false,
      })
      -- GitSignsUpdate skips moves that leave the add/change/delete totals
      -- unchanged. Scrollview still needs the new line positions in that case.
      local previous_status = {}
      require("gitsigns.manager").on_update(function(ctx)
        local status = vim.b[ctx.bufnr].gitsigns_status_dict
        if vim.deep_equal(previous_status[ctx.bufnr], status) then
          vim.api.nvim_exec_autocmds("User", {
            pattern = "GitSignsUpdate",
            modeline = false,
            data = { buffer = ctx.bufnr },
          })
        end
        previous_status[ctx.bufnr] = vim.deepcopy(status)
      end)
    end,
  },
}
