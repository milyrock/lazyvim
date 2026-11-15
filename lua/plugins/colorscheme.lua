local transparent_groups = {
  "Normal",
  "NormalNC",
  "NormalFloat",
  "FloatBorder",
  "SignColumn",
  "EndOfBuffer",
  "LineNr",
  "FoldColumn",
  "StatusLine",
  "StatusLineNC",
  "TabLineFill",
  "NeoTreeNormal",
  "NeoTreeNormalNC",
}

local function clear_backgrounds()
  for _, group in ipairs(transparent_groups) do
    pcall(vim.cmd.highlight, group .. " guibg=NONE ctermbg=NONE")
  end
end

local function fortnite_mocha()
  return {
    flavour = "mocha",
    transparent_background = true,
    color_overrides = {
      mocha = {
        rosewater = "#ffcc66",
        flamingo = "#ff6b9d",
        pink = "#ff4fd8",
        mauve = "#9d7dff",
        red = "#ff4e6a",
        maroon = "#ff7a4d",
        peach = "#ff9f1c",
        yellow = "#ffe66d",
        green = "#62ff7e",
        teal = "#2dffc6",
        sky = "#38d5ff",
        sapphire = "#3aa0ff",
        blue = "#4d7cff",
        lavender = "#b7a9ff",
        text = "#f8fbff",
        subtext1 = "#e1e7ff",
        subtext0 = "#cad2ff",
        overlay2 = "#adb8ec",
        overlay1 = "#98a4dd",
        overlay0 = "#828dc7",
        surface2 = "#646b9a",
        surface1 = "#4d547d",
        surface0 = "#3a4065",
        base = "#171827",
        mantle = "#11131f",
        crust = "#0b0d16",
      },
    },
    custom_highlights = function(colors)
      local ui_accent = "#d48da5"

      return {
        Comment = { fg = colors.overlay2, style = { "italic" } },
        -- Function colors, including semantic highlighting.
        Function = { fg = colors.peach, style = { "bold" } },
        ["@function.call"] = { fg = colors.peach, style = { "bold" } },
        ["@function.method.call"] = { link = "@function.call" },
        ["@lsp.type.function"] = { link = "@function.call" },
        ["@lsp.type.method"] = { link = "@function.call" },
        ["@lsp.typemod.function.declaration"] = { link = "Function" },
        ["@lsp.typemod.function.definition"] = { link = "Function" },
        ["@lsp.typemod.method.declaration"] = { link = "Function" },
        ["@lsp.typemod.method.definition"] = { link = "Function" },
        ["@keyword.go"] = { fg = "#28e6de", style = { "bold" } },
        ["@keyword.type.go"] = { link = "@keyword.go" },
        ["@keyword.function.go"] = { link = "@keyword.go" },
        ["@keyword.return.go"] = { link = "@keyword.go" },
        ["@keyword.coroutine.go"] = { link = "@keyword.go" },
        ["@keyword.repeat.go"] = { link = "@keyword.go" },
        ["@keyword.import.go"] = { link = "@keyword.go" },
        ["@keyword.conditional.go"] = { link = "@keyword.go" },
        ["@lsp.type.keyword.go"] = { link = "@keyword.go" },
        Keyword = { fg = colors.pink, style = { "bold" } },
        Statement = { fg = colors.mauve, style = { "bold" } },
        Conditional = { fg = colors.mauve, style = { "bold" } },
        Repeat = { fg = colors.mauve, style = { "bold" } },
        String = { fg = "#e394dc" },
        Number = { fg = "#ebc88d" },
        Boolean = { fg = colors.peach, style = { "bold" } },
        Type = { fg = "#87c3ff", style = { "bold" } },
        ["@type.builtin"] = { fg = "#87c3ff" },
        ["@lsp.type.struct.go"] = { fg = colors.peach, style = { "bold" } },
        ["@lsp.typemod.type.struct.go"] = { link = "@lsp.type.struct.go" },
        Identifier = { fg = colors.lavender },
        ["@variable.member.go"] = { fg = "#a98aff" },
        ["@property.go"] = { link = "@variable.member.go" },
        ["@lsp.type.property.go"] = { link = "@variable.member.go" },
        Constant = { fg = colors.peach },
        Operator = { fg = colors.teal },
        Special = { fg = colors.flamingo },
        Directory = { fg = colors.sky, style = { "bold" } },
        LineNr = { fg = colors.overlay0 },
        CursorLineNr = { fg = colors.yellow, style = { "bold" } },
        WinSeparator = { fg = colors.surface2 },
        Visual = { bg = colors.surface1, style = { "bold" } },
        CursorLine = { bg = colors.surface0 },
        Search = { fg = colors.crust, bg = colors.yellow, style = { "bold" } },
        IncSearch = { fg = colors.crust, bg = colors.peach, style = { "bold" } },
        MatchParen = { fg = colors.yellow, bg = colors.surface1, style = { "bold" } },
        DiagnosticError = { fg = colors.red },
        DiagnosticWarn = { fg = colors.yellow },
        DiagnosticInfo = { fg = colors.sky },
        DiagnosticHint = { fg = colors.green },
        NeoTreeDirectoryName = { fg = colors.sky },
        NeoTreeDirectoryIcon = { fg = colors.blue },
        NeoTreeFileNameOpened = { fg = colors.green, style = { "bold" } },
        -- Saturated diff backgrounds preserve the code's syntax colors.
        GitSignsAddPreview = { fg = "NONE", style = {}, bg = "#1c5032" },
        GitSignsDeleteVirtLn = { fg = "NONE", style = {}, bg = "#702530" },
        GitSignsAddInline = { fg = "NONE", style = {}, bg = "#2c7144" },
        GitSignsChangeInline = { fg = "NONE", style = {}, bg = "#2c7144" },
        GitSignsDeleteInline = { fg = "NONE", style = {}, bg = "#9b3342" },
        GitSignsDeleteVirtLnInLine = { fg = "NONE", style = {}, bg = "#9b3342" },
        GitSignsVirtLnum = { fg = "#ff9ba8", bg = "#702530" },
        WhichKey = { fg = colors.sky, style = { "bold" } },
        WhichKeyGroup = { fg = colors.pink },
        -- Muted UI accents without changing the code palette.
        SnacksDashboardHeader = { fg = ui_accent },
        SnacksDashboardDesc = { fg = "#d6d6dd" },
        SnacksPickerBorder = { fg = "#888888" },
        SnacksPickerTitle = { fg = colors.text, bg = "#252525" },
        SnacksPickerDirectory = { fg = ui_accent, style = { "bold" } },
        SnacksPickerMatch = { fg = ui_accent },
        SnacksPickerDir = { fg = "#a0a0a0" },
        SnacksPickerTotals = { fg = "#a0a0a0" },
        SnacksPickerListCursorLine = { bg = "#414141", style = { "bold" } },
        SnacksPickerPreviewCursorLine = { link = "SnacksPickerListCursorLine" },
        SnacksPickerSelected = { fg = colors.text, bg = "#414141", style = { "bold" } },
        MiniIconsAzure = { fg = ui_accent },
        MiniIconsBlue = { fg = ui_accent },
      }
    end,
  }
end

return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    opts = fortnite_mocha(),
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = function()
        require("catppuccin").setup(fortnite_mocha())
        vim.cmd.colorscheme("catppuccin")
        clear_backgrounds()

        vim.api.nvim_create_autocmd("ColorScheme", {
          callback = function()
            vim.schedule(clear_backgrounds)
          end,
        })
      end,
    },
  },
}
