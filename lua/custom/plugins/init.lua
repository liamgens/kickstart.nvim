-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information
return {
  {
    'christoomey/vim-tmux-navigator',
    cmd = {
      'TmuxNavigateLeft',
      'TmuxNavigateDown',
      'TmuxNavigateUp',
      'TmuxNavigateRight',
      'TmuxNavigatePrevious',
    },
    keys = {
      { '<c-h>', '<cmd><C-U>TmuxNavigateLeft<cr>' },
      { '<c-j>', '<cmd><C-U>TmuxNavigateDown<cr>' },
      { '<c-k>', '<cmd><C-U>TmuxNavigateUp<cr>' },
      { '<c-l>', '<cmd><C-U>TmuxNavigateRight<cr>' },
      { '<c-\\>', '<cmd><C-U>TmuxNavigatePrevious<cr>' },
    },
  },
  {
    'nvim-tree/nvim-tree.lua',
    version = '*',
    lazy = false,
    keys = {
      { '<leader>e', '<cmd>NvimTreeToggle<CR>', desc = 'nvim tree' },
    },
    config = function()
      require('nvim-tree').setup {
        renderer = {
          icons = {
            glyphs = {
              folder = {
                arrow_open = '[-]',
                arrow_closed = '[+]',
              },
            },
            show = {
              file = false,
              folder = false,
              folder_arrow = true,
              git = false,
            },
          },
        },
        on_attach = function(bufnr)
          local api = require('nvim-tree.api')

          -- Default mappings
          api.config.mappings.default_on_attach(bufnr)

          -- Custom mapping: <leader>e to close nvim-tree when focused on it
          vim.keymap.set('n', '<leader>e', '<cmd>NvimTreeToggle<CR>', { buffer = bufnr, desc = 'nvim tree' })
        end,
      }
    end,
  },
  {
    'greggh/claude-code.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim', -- Required for git operations
    },
    config = function()
      require('claude-code').setup {
        -- Terminal window settings
        window = {
          split_ratio = 0.3, -- Percentage of screen for the terminal window (height for horizontal, width for vertical splits)
          position = 'float', -- Position of the window: "botright", "topleft", "vertical", "float", etc.
          enter_insert = true, -- Whether to enter insert mode when opening Claude Code
          hide_numbers = true, -- Hide line numbers in the terminal window
          hide_signcolumn = true, -- Hide the sign column in the terminal window

          -- Floating window configuration (only applies when position = "float")
          float = {
            width = '80%', -- Width: number of columns or percentage string
            height = '80%', -- Height: number of rows or percentage string
            row = 'center', -- Row position: number, "center", or percentage string
            col = 'center', -- Column position: number, "center", or percentage string
            relative = 'editor', -- Relative to: "editor" or "cursor"
            border = 'none', -- Border style: "none", "single", "double", "rounded", "solid", "shadow"
          },
        },
        -- File refresh settings
        refresh = {
          enable = true, -- Enable file change detection
          updatetime = 100, -- updatetime when Claude Code is active (milliseconds)
          timer_interval = 1000, -- How often to check for file changes (milliseconds)
          show_notifications = true, -- Show notification when files are reloaded
        },
        -- Git project settings
        git = {
          use_git_root = true, -- Set CWD to git root when opening Claude Code (if in git project)
        },
        -- Shell-specific settings
        shell = {
          separator = '&&', -- Command separator used in shell commands
          pushd_cmd = 'pushd', -- Command to push directory onto stack (e.g., 'pushd' for bash/zsh, 'enter' for nushell)
          popd_cmd = 'popd', -- Command to pop directory from stack (e.g., 'popd' for bash/zsh, 'exit' for nushell)
        },
        -- Command settings
        command = 'claude', -- Command used to launch Claude Code
        -- Command variants
        command_variants = {
          -- Conversation management
          continue = '--continue', -- Resume the most recent conversation
          resume = '--resume', -- Display an interactive conversation picker

          -- Output options
          verbose = '--verbose', -- Enable verbose logging with full turn-by-turn output
        },
        -- Keymaps
        keymaps = {
          toggle = {
            normal = '<C-g>', -- Normal mode keymap for toggling Claude Code, false to disable
            terminal = '<C-g>', -- Terminal mode keymap for toggling Claude Code, false to disable
            variants = {
              continue = '<leader>cC', -- Normal mode keymap for Claude Code with continue flag
              verbose = '<leader>cV', -- Normal mode keymap for Claude Code with verbose flag
            },
          },
          window_navigation = true, -- Enable window navigation keymaps (<C-h/j/k/l>)
          scrolling = true, -- Enable scrolling keymaps (<C-f/b>) for page up/down
        },
      }
    end,
  },
  {
    'nmac427/guess-indent.nvim',
    event = 'BufReadPre',
    config = function()
      require('guess-indent').setup {
        auto_cmd = true, -- Automatically detect indentation on buffer open
        override_editorconfig = false, -- Don't override editorconfig settings
        filetype_exclude = {
          'netrw',
          'tutor',
        },
        buftype_exclude = {
          'help',
          'nofile',
          'terminal',
          'prompt',
        },
      }
    end,
  },
  {
    {
      'b0o/incline.nvim',
      config = function()
        require('incline').setup {
          render = function(props)
            local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ':t')
            if filename == '' then
              filename = '[No Name]'
            end

            local function get_git_diff()
              local icons = { removed = '-', changed = '~', added = '+' }
              local signs = vim.b[props.buf].gitsigns_status_dict
              local labels = {}
              if signs == nil then
                return labels
              end
              for name, icon in pairs(icons) do
                if tonumber(signs[name]) and signs[name] > 0 then
                  table.insert(labels, { icon .. signs[name] .. ' ', group = 'Diff' .. name })
                end
              end
              if #labels > 0 then
                table.insert(labels, { '┊ ' })
              end
              return labels
            end

            local function get_diagnostic_label()
              local icons = { error = 'X', warn = '!', info = 'I', hint = '?' }
              local label = {}

              for severity, icon in pairs(icons) do
                local n = #vim.diagnostic.get(props.buf, { severity = vim.diagnostic.severity[string.upper(severity)] })
                if n > 0 then
                  table.insert(label, { icon .. n .. ' ', group = 'DiagnosticSign' .. severity })
                end
              end
              if #label > 0 then
                table.insert(label, { '┊ ' })
              end
              return label
            end

            return {
              { get_diagnostic_label() },
              { get_git_diff() },
              { filename .. ' ', gui = vim.bo[props.buf].modified and 'bold,italic' or 'bold' },
            }
          end,
        }
      end,
      -- Optional: Lazy load Incline
      event = 'VeryLazy',
    },
  },
  {
    'folke/trouble.nvim',
    opts = {
      icons = {
        indent = {
          fold_open = '-',
          fold_closed = '+',
        },
        folder_closed = ' ',
        folder_open = ' ',
        kinds = {},
      },
      modes = {
        diagnostics = {
          format = '{severity_icon} {filename}:{lnum} {message}',
        },
      },
      use_diagnostic_signs = true,
    },
    cmd = 'Trouble',
    keys = {
      {
        '<leader>xx',
        '<cmd>Trouble diagnostics toggle<cr>',
        desc = 'Diagnostics (Trouble)',
      },
      {
        '<leader>xX',
        '<cmd>Trouble diagnostics toggle filter.buf=0<cr>',
        desc = 'Buffer Diagnostics (Trouble)',
      },
      {
        '<leader>xs',
        '<cmd>Trouble symbols toggle focus=false<cr>',
        desc = 'Symbols (Trouble)',
      },
      {
        '<leader>xl',
        '<cmd>Trouble lsp toggle focus=false win.position=right<cr>',
        desc = 'LSP Definitions / references / ... (Trouble)',
      },
      {
        '<leader>xL',
        '<cmd>Trouble loclist toggle<cr>',
        desc = 'Location List (Trouble)',
      },
      {
        '<leader>xQ',
        '<cmd>Trouble qflist toggle<cr>',
        desc = 'Quickfix List (Trouble)',
      },
    },
  },
}
