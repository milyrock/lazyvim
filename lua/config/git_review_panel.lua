local function position_counts(bufnr)
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return
  end
  local ns = vim.api.nvim_get_namespaces().gitsigns_diff
  if not ns then
    return
  end
  for _, mark in ipairs(vim.api.nvim_buf_get_extmarks(bufnr, ns, 0, -1, { details = true })) do
    local detail = mark[4]
    if detail.virt_text_pos == "right_align" and detail.virt_text then
      local chunks = vim.deepcopy(detail.virt_text)
      chunks[#chunks + 1] = { " ", "Normal" }
      -- Keep counts before the status and filename, away from the clipped edge.
      vim.api.nvim_buf_set_extmark(bufnr, ns, mark[2], mark[3], {
        id = mark[1],
        end_row = detail.end_row,
        end_col = detail.end_col,
        hl_group = detail.hl_group,
        virt_text = chunks,
        virt_text_pos = "inline",
        hl_mode = "combine",
        priority = detail.priority,
      })
    end
  end
end

return function(bufnr)
  local function refresh()
    vim.schedule(function() position_counts(bufnr) end)
  end
  -- Panel refreshes replace its decorations after updating the buffer text.
  vim.api.nvim_buf_attach(bufnr, false, { on_lines = refresh, on_reload = refresh })
  refresh()
end
