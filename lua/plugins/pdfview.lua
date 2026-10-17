return {
  {
    "basola21/PDFview",
    lazy = false,
    dependencies = { "nvim-telescope/telescope.nvim" },
    init = function()
      local poppler_bin = "/opt/homebrew/opt/poppler/bin"
      if vim.fn.executable(poppler_bin .. "/pdftotext") == 1 then
        vim.env.PATH = poppler_bin .. ":" .. vim.env.PATH
      end

      vim.api.nvim_create_autocmd("BufReadPost", {
        pattern = "*.pdf",
        callback = function()
          require("pdfview").open(vim.api.nvim_buf_get_name(0))
        end,
      })
    end,
  },
}
