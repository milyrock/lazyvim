return {
  {
    "folke/snacks.nvim",
    opts = function(_, opts)
      local cache = {}

      local function git(root, args)
        local cmd = { "git", "-C", root }
        vim.list_extend(cmd, args)

        local result = vim.system(cmd, { text = true }):wait()
        if result.code ~= 0 then
          return nil
        end

        return vim.trim(result.stdout or "")
      end

      local function locally_changed_files(cwd)
        local root = Snacks.git.get_root(cwd)
        if not root then
          return {}
        end

        local now = vim.uv.now()
        if cache[root] and now - cache[root].time < 1000 then
          return cache[root].files
        end

        -- Prefer the remote version of the current branch. For a branch that
        -- has never been pushed, fall back to the remote default branch.
        local base = git(root, {
          "rev-parse",
          "--abbrev-ref",
          "--symbolic-full-name",
          "@{upstream}",
        })
        if not base then
          base = git(root, {
            "symbolic-ref",
            "--short",
            "refs/remotes/origin/HEAD",
          }) or "origin/master"
        end

        local output = git(root, { "diff", "--name-only", base, "--" }) or ""
        local files = {}
        for path in output:gmatch("[^\r\n]+") do
          local full_path = vim.fs.normalize(root .. "/" .. path)
          files[full_path] = true

          -- Mark every parent directory so a changed file remains visible
          -- even while its containing directories are collapsed.
          local parent = vim.fs.dirname(full_path)
          while parent and parent ~= root do
            files[parent] = true
            local next_parent = vim.fs.dirname(parent)
            if next_parent == parent then
              break
            end
            parent = next_parent
          end
        end

        cache[root] = { time = now, files = files }
        return files
      end

      opts.picker = opts.picker or {}
      opts.picker.sources = opts.picker.sources or {}
      opts.picker.sources.lsp_implementations = vim.tbl_deep_extend(
        "force",
        opts.picker.sources.lsp_implementations or {},
        { pattern = "!mock" }
      )
      opts.picker.sources.explorer = opts.picker.sources.explorer or {}
      opts.picker.sources.explorer.format = function(item, picker)
        -- Preserve Snacks' normal colors for unstaged/staged/untracked files.
        -- Add a green filename highlight only for clean files whose changes
        -- are committed locally but have not reached the upstream branch yet.
        if item.file and not item.status then
          local files = locally_changed_files(picker:cwd())
          if files[vim.fs.normalize(item.file)] then
            item.filename_hl = "SnacksPickerGitStatusStaged"
          end
        end

        return Snacks.picker.format.file(item, picker)
      end
    end,
  },
}
