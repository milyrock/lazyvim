local function git(bufnr, ...)
  local dir = vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr))
  local cmd = { "git", "-C", dir }
  vim.list_extend(cmd, { ... })
  local result = vim.system(cmd, { text = true }):wait()
  return result.code == 0 and vim.trim(result.stdout) or nil
end

local function branch_base(bufnr)
  local default = git(bufnr, "symbolic-ref", "--short", "refs/remotes/origin/HEAD")
  for _, ref in ipairs({ default or "origin/master", "origin/main", "master", "main" }) do
    local base = git(bufnr, "merge-base", "HEAD", ref)
    if base then
      return base
    end
  end
  return "HEAD"
end

local labels = {
  branch = "branch changes + current edits",
  commit = "latest commit + current edits",
  working = "uncommitted changes",
}

local function restore_inline_options(win)
  if not vim.api.nvim_win_is_valid(win) then
    return
  end
  local saved = vim.w[win].git_review_view_options
  if saved then
    for key, value in pairs(saved) do
      vim.wo[win][key] = value
    end
    vim.w[win].git_review_view_options = nil
  end
end

local function toggle_inline(bufnr)
  local win = vim.api.nvim_get_current_win()
  local active = require("gitsigns.unified").get_view(win) ~= nil
  if not active then
    vim.w[win].git_review_view_options = {
      number = vim.wo[win].number,
      relativenumber = vim.wo[win].relativenumber,
      cursorline = vim.wo[win].cursorline,
    }
    vim.wo[win].number = true
    vim.wo[win].relativenumber = false
    vim.wo[win].cursorline = false
  end
  require("gitsigns").diffthis(vim.b[bufnr].git_review_base or branch_base(bufnr), { unified = true })
  if active then
    restore_inline_options(win)
  end
end

local function compare(bufnr, mode, quiet)
  local gs = require("gitsigns")
  local base = mode == "branch" and branch_base(bufnr) or mode == "commit" and "HEAD~1" or "HEAD"
  if not git(bufnr, "rev-parse", "--verify", base .. "^{commit}") then
    if not quiet then
      vim.notify("No parent commit is available for this comparison", vim.log.levels.WARN)
    end
    return
  end
  vim.api.nvim_buf_call(bufnr, function()
    local reopen = require("gitsigns.unified").get_view() ~= nil
    if reopen then
      gs.diffthis(nil, { unified = true })
    end
    vim.b[bufnr].git_review_mode = mode
    vim.b[bufnr].git_review_base = base
    gs.change_base(base, false, function(err)
      if err then
        vim.notify("Git comparison failed: " .. err, vim.log.levels.ERROR)
        return
      end
      if not vim.api.nvim_buf_is_valid(bufnr) then
        return
      end
      vim.api.nvim_buf_call(bufnr, function()
        if reopen then
          gs.diffthis(base, { unified = true })
        end
        if not quiet then
          vim.notify("Showing " .. labels[mode], vim.log.levels.INFO, { title = "Git changes" })
        end
      end)
    end)
  end)
end

local function in_git_buffer(callback)
  local bufnr = vim.api.nvim_get_current_buf()
  local gs = require("gitsigns")
  if vim.bo[bufnr].buftype ~= "" then
    vim.notify("Open a normal file in a Git repository first", vim.log.levels.WARN)
    return
  end
  if gs.get_hunks(bufnr) == nil then
    gs.attach({ bufnr = bufnr })
    if not vim.wait(1500, function() return gs.get_hunks(bufnr) ~= nil end, 20) then
      vim.notify("Git changes are unavailable for this file", vim.log.levels.WARN)
      return
    end
  end
  callback(bufnr)
end

local function open_review(latest_commit)
  local buf = vim.api.nvim_get_current_buf()
  local base
  if not latest_commit then
    base = vim.b[buf].git_review_base
    if not base and vim.bo[buf].buftype == "" and vim.api.nvim_buf_get_name(buf) ~= "" then
      base = branch_base(buf)
    end
  end
  require("gitsigns").diff(base, nil, { diff = "unified", commit = latest_commit }, function(err)
    if err then
      vim.notify("Git review failed: " .. err, vim.log.levels.ERROR)
      return
    end
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
      if require("gitsigns.unified").get_view(win) then
        vim.wo[win].number = true
        vim.wo[win].relativenumber = false
        vim.wo[win].cursorline = false
      end
    end
  end)
end

return {
  {
    "lewis6991/gitsigns.nvim",
    keys = {
      { "<leader>go", function() open_review(false) end, desc = "Review changes (inline + file tree)" },
      { "<leader>gO", function() open_review(true) end, desc = "Review latest commit (inline + file tree)" },
      { "<leader>ghm", function() in_git_buffer(function(buf) compare(buf, "branch") end) end,
        desc = "Show branch changes" },
      { "<leader>ghc", function() in_git_buffer(function(buf) compare(buf, "commit") end) end,
        desc = "Show latest commit + edits" },
      { "<leader>ghw", function() in_git_buffer(function(buf) compare(buf, "working") end) end,
        desc = "Show uncommitted changes" },
      { "<leader>ghv", function()
        in_git_buffer(toggle_inline)
      end, desc = "Toggle inline Git diff" },
      { "]h", function()
        in_git_buffer(function()
          if vim.wo.diff then vim.cmd.normal({ "]c", bang = true })
          else require("gitsigns").nav_hunk("next") end
        end)
      end, desc = "Next Git change" },
      { "[h", function()
        in_git_buffer(function()
          if vim.wo.diff then vim.cmd.normal({ "[c", bang = true })
          else require("gitsigns").nav_hunk("prev") end
        end)
      end, desc = "Previous Git change" },
    },
    opts = function(_, opts)
      local original_on_attach = opts.on_attach
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "gitsigns-diff",
        group = vim.api.nvim_create_augroup("GitReviewPanel", { clear = true }),
        callback = function(event)
          require("config.git_review_panel")(event.buf)
        end,
      })
      vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter" }, {
        group = vim.api.nvim_create_augroup("GitReviewAppearance", { clear = true }),
        callback = function()
          local win = vim.api.nvim_get_current_win()
          vim.schedule(function()
            if vim.api.nvim_win_is_valid(win) and not require("gitsigns.unified").get_view(win) then
              restore_inline_options(win)
            end
          end)
        end,
      })
      opts.base = nil
      opts.on_attach = function(bufnr)
        if original_on_attach and original_on_attach(bufnr) == false then
          return false
        end
        -- Use the global lazy mappings even if attach happened before key setup.
        for _, key in ipairs({ "<leader>ghm", "<leader>ghc", "<leader>ghw", "<leader>ghv", "]h", "[h" }) do
          pcall(vim.keymap.del, "n", key, { buffer = bufnr })
        end
        -- Changing the base during the initial diff can lose its result.
        vim.api.nvim_create_autocmd("User", {
          pattern = "GitSignsUpdate",
          callback = function(event)
            if not vim.api.nvim_buf_is_valid(bufnr) then
              return true
            end
            if event.data and event.data.buffer == bufnr then
              vim.schedule(function()
                if vim.api.nvim_buf_is_valid(bufnr) and not vim.b[bufnr].git_review_mode then
                  compare(bufnr, "branch", true)
                end
              end)
              return true
            end
          end,
        })
      end
      return opts
    end,
  },
}
