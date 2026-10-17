return {
  {
    "lewis6991/gitsigns.nvim",
    opts = function(_, opts)
      local original_on_attach = opts.on_attach

      -- Keep branch changes visible after commit by comparing buffers with
      -- the remote default branch instead of the index/HEAD.
      opts.base = "origin/master"
      opts.on_attach = function(bufnr)
        if original_on_attach then
          original_on_attach(bufnr)
        end

        -- Apply the base only after this buffer is fully registered in the
        -- gitsigns cache. This also covers buffers restored during startup.
        vim.schedule(function()
          if vim.api.nvim_buf_is_valid(bufnr) then
            vim.api.nvim_buf_call(bufnr, function()
              require("gitsigns").change_base("origin/master")
            end)
          end
        end)
      end

      return opts
    end,
  },
}
