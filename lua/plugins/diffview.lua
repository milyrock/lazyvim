return {
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory" },
    keys = {
      { "<leader>go", "<cmd>DiffviewOpen master<cr>", desc = "Diff with master" },
    },
  },
}
