# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a Neovim configuration based on kickstart.nvim - a single-file, documented starting point for Neovim. The configuration is designed to be minimal, well-documented, and easy to understand.

## Architecture

### File Structure

- `init.lua` - Main configuration file containing all core settings, plugin definitions, and keymaps
- `lua/custom/plugins/init.lua` - Custom plugin definitions loaded via lazy.nvim
- `lazy-lock.json` - Plugin version lockfile (tracked in version control)

### Plugin Management

Uses lazy.nvim as the plugin manager. Plugins are lazy-loaded when possible for performance.

Main plugin loading happens in `init.lua` around line 156 with `require('lazy').setup()`.

Custom plugins are imported from `lua/custom/plugins/` (line 811).

### Core Plugin Architecture

**LSP Configuration** (init.lua:163-442)
- Mason for LSP/tool installation
- nvim-lspconfig for LSP server configuration
- LSP servers configured: gopls, ts_ls, lua_ls
- Auto-install tools: stylua, prettier, goimports
- LSP keymaps use 'gr' prefix (e.g., grn for rename, grd for definition)
- Capabilities are extended by blink.cmp (line 351)

**Completion** (init.lua:486-583)
- blink.cmp for autocompletion with 'default' preset (Ctrl-y to accept)
- LuaSnip for snippets
- lazydev for Neovim Lua API completion
- Documentation shown with Ctrl-Space (auto_show disabled by default)

**Formatting** (init.lua:444-484)
- conform.nvim handles autoformatting on save
- Per-language formatters configured in `formatters_by_ft`
- LSP fallback enabled except for C/C++

**Mini.nvim Suite** (init.lua:617-764)
- mini.ai: Enhanced text objects
- mini.surround: Surround operations (saiw, sd, sr)
- mini.pairs: Auto-pairing
- mini.statusline: Minimalist statusline (mode, git branch, location only)
- mini.pick: File/buffer/grep picker (no icons, hjkl navigation with Ctrl-j/k)
- mini.extra: Additional pickers including LSP
- mini.clue: Key hint system (replaces which-key)

**Treesitter** (init.lua:766-790)
- Syntax highlighting and incremental parsing
- Auto-install enabled for languages

### Custom Plugins (lua/custom/plugins/init.lua)

- **vim-tmux-navigator**: Seamless tmux/vim navigation with Ctrl-hjkl
- **nvim-tree**: File explorer (toggle with `<leader>e`), no icons
- **claude-code.nvim**: Integration for Claude Code in floating window (Ctrl-g to toggle)
- **guess-indent.nvim**: Auto-detect indentation per file
- **incline.nvim**: Floating filename labels showing diagnostics and git status
- **trouble.nvim**: Diagnostics list (`<leader>x` prefix)

### Configuration Preferences

**No Icons/Nerd Fonts**
- `vim.g.have_nerd_font = false` (line 13)
- All plugins configured to use text-only symbols
- Diagnostic signs: X (error), ! (warn), I (info), ? (hint)

**Indentation**
- Default: 2 spaces (expandtab, shiftwidth=2, softtabstop=2)
- guess-indent.nvim auto-detects per file

**Global Statusline**
- Single statusline spanning full width (`laststatus = 3`)
- Shows: mode, git branch, line:column

## Common Commands

### Plugin Management
```vim
:Lazy              " View plugin status
:Lazy update       " Update all plugins
:Lazy sync         " Sync plugins with lockfile
```

### LSP & Tools
```vim
:Mason             " Manage LSP servers and tools (press g? for help)
:ConformInfo       " View formatter configuration
:LspInfo           " View LSP client status
```

### Development Workflow

**Opening Files**
- `<leader>ff` - Find files (mini.pick)
- `<leader>fb` - Switch buffers
- `<leader>fg` - Live grep
- `<leader>e` - Toggle file explorer

**LSP Navigation**
- `grd` - Go to definition
- `grr` - Find references (mini.extra)
- `grn` - Rename symbol
- `gra` - Code actions
- `gri` - Go to implementation
- `grt` - Go to type definition

**Diagnostics**
- `<leader>xx` - Toggle diagnostics (Trouble)
- `<leader>xX` - Buffer diagnostics only

**Window Management**
- `<leader>w` prefix for all window commands (split, close, resize, etc.)
- `<C-h/j/k/l>` - Navigate between vim/tmux panes

**Claude Code**
- `<C-g>` - Toggle Claude Code floating window
- `<leader>cC` - Continue last conversation
- `<leader>cV` - Verbose mode

## Key Implementation Details

### LSP Attach Behavior (init.lua:220-314)
- LSP keymaps are set per-buffer when LSP attaches
- Document highlight on cursor hold (if supported by server)
- Automatic cleanup on LSP detach

### Diagnostic Configuration (init.lua:319-345)
- Severity sorting enabled
- Rounded borders on float windows
- Only ERROR severity underlined
- Virtual text shows full diagnostic message

### Gopls Specific (init.lua:368-385)
- Disabled didChangeWatchedFiles to avoid performance issues
- Gofumpt and staticcheck enabled
- Supports gotmpl files

### Colorscheme
- Currently using zenbones 'neobones' variant
- Comments darkened by 45%
- Lackluster theme available but commented out (lines 584-600)

## Notes for Modifications

- When adding new LSP servers, add them to the `servers` table (line 362) and ensure_installed list (line 419)
- For new formatters, update `formatters_by_ft` in conform.nvim config (line 464)
- Custom keymaps should use descriptive `desc` fields for mini.clue integration
- Leader key is space (`<leader>` = space)
- Keep init.lua well-commented - this is a teaching configuration
- Test changes by restarting Neovim (`:qa` then reopen)
