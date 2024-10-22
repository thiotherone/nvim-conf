-- opts = function()
--   local mason_registry = require("mason-registry")
--   local lombok_jar = mason_registry.get_package("jdtls"):get_install_path() .. "/lombok.jar"
--   return {
--     -- How to find the root dir for a given filename. The default comes from
--     -- lspconfig which provides a function specifically for java projects.
--     root_dir = LazyVim.lsp.get_raw_config("jdtls").default_config.root_dir,
--
--     -- How to find the project name for a given root dir.
--     project_name = function(root_dir)
--       return root_dir and vim.fs.basename(root_dir)
--     end,
--
--     -- Where are the config and workspace dirs for a project?
--     jdtls_config_dir = function(project_name)
--       return vim.fn.stdpath("cache") .. "/jdtls/" .. project_name .. "/config"
--     end,
--     jdtls_workspace_dir = function(project_name)
--       return vim.fn.stdpath("cache") .. "/jdtls/" .. project_name .. "/workspace"
--     end,
--
--     -- How to run jdtls. This can be overridden to a full java command-line
--     -- if the Python wrapper script doesn't suffice.
--     cmd = {
--       vim.fn.exepath("jdtls"),
--       string.format("--jvm-arg=-javaagent:%s", lombok_jar),
--     },
--     full_cmd = function(opts)
--       local fname = vim.api.nvim_buf_get_name(0)
--       local root_dir = opts.root_dir(fname)
--       local project_name = opts.project_name(root_dir)
--       local cmd = vim.deepcopy(opts.cmd)
--       if project_name then
--         vim.list_extend(cmd, {
--           "-configuration",
--           opts.jdtls_config_dir(project_name),
--           "-data",
--           opts.jdtls_workspace_dir(project_name),
--         })
--       end
--       return cmd
--     end,
--
--     -- These depend on nvim-dap, but can additionally be disabled by setting false here.
--     dap = { hotcodereplace = "auto", config_overrides = {} },
--     dap_main = {},
--     test = true,
--     settings = {
--       java = {
--         inlayHints = {
--           parameterNames = {
--             enabled = "all",
--           },
--         },
--       },
--     },
--   }
-- end
--
--
-- return {
--   {
--     "neovim/nvim-lspconfig",
--     dependencies = { "mfussenegger/nvim-jdtls" },
--     opts = {
--       setup = {
--         jdtls = function(_, opts)
--           vim.api.nvim_create_autocmd("FileType", {
--             pattern = "java",
--             callback = function()
--               require("lazyvim.util").on_attach(function(_, buffer)
--                 vim.keymap.set(
--                   "n",
--                   "<leader>di",
--                   "<Cmd>lua require'jdtls'.organize_imports()<CR>",
--                   { buffer = buffer, desc = "Organize Imports" }
--                 )
--                 vim.keymap.set(
--                   "n",
--                   "<leader>dt",
--                   "<Cmd>lua require'jdtls'.test_class()<CR>",
--                   { buffer = buffer, desc = "Test Class" }
--                 )
--                 vim.keymap.set(
--                   "n",
--                   "<leader>dn",
--                   "<Cmd>lua require'jdtls'.test_nearest_method()<CR>",
--                   { buffer = buffer, desc = "Test Nearest Method" }
--                 )
--                 vim.keymap.set(
--                   "v",
--                   "<leader>de",
--                   "<Esc><Cmd>lua require('jdtls').extract_variable(true)<CR>",
--                   { buffer = buffer, desc = "Extract Variable" }
--                 )
--                 vim.keymap.set(
--                   "n",
--                   "<leader>de",
--                   "<Cmd>lua require('jdtls').extract_variable()<CR>",
--                   { buffer = buffer, desc = "Extract Variable" }
--                 )
--                 vim.keymap.set(
--                   "v",
--                   "<leader>dm",
--                   "<Esc><Cmd>lua require('jdtls').extract_method(true)<CR>",
--                   { buffer = buffer, desc = "Extract Method" }
--                 )
--                 vim.keymap.set(
--                   "n",
--                   "<leader>cf",
--                   "<cmd>lua vim.lsp.buf.formatting()<CR>",
--                   { buffer = buffer, desc = "Format" }
--                 )
--               end)
--
--               local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
--               vim.lsp.set_log_level "DEBUG"
--               local workspace_dir = "/home/void/.cache/jdtls/workspace/" .. project_name -- See `:help vim.lsp.start_client` for an overview of the supported `config` options.
--               local config = {
--                 -- The command that starts the language server
--                 -- See: https://github.com/eclipse/eclipse.jdt.ls#running-from-the-command-line
--                 -- cmd = {
--                 -- --
--                 --   "java", -- or '/path/to/java17_or_newer/bin/java'
--                 -- --   -- depends on if `java` is in your $PATH env variable and if it points to the right version.
--                 -- --
--                 -- --   "-javaagent:/home/void/.local/share/java/lombok.jar",
--                 -- --   -- '-Xbootclasspath/a:/home/jake/.local/share/java/lombok.jar',
--                 --   "-Declipse.application=org.eclipse.jdt.ls.core.id1",
--                 --   "-Dosgi.bundles.defaultStartLevel=4",
--                 --   "-Declipse.product=org.eclipse.jdt.ls.core.product",
--                 --   "-Dlog.protocol=true",
--                 --   "-Dlog.level=ALL",
--                 --   '-noverify',
--                 --   "-Xms1g",
--                 --   "--add-modules=ALL-SYSTEM",
--                 --   "--add-opens",
--                 --   "java.base/java.util=ALL-UNNAMED",
--                 --   "--add-opens",
--                 --   "java.base/java.lang=ALL-UNNAMED",
--                 --   "-jar",
--                 --   vim.fn.glob("/home/void/Github/jdtls/plugins/org.eclipse.equinox.launcher_1.6.400.v20210924-0641.jar"),
--                 -- --   -- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^                                       ^^^^^^^^^^^^^^
--                 -- --   -- Must point to the                                                     Change this to
--                 -- --   -- eclipse.jdt.ls installation                                           the actual version
--                 -- --
--                 --   "-configuration",
--                 --   "/home/void/Github/jdtls/config_linux",
--                 -- --   -- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^        ^^^^^^
--                 -- --   -- Must point to the                      Change to one of `linux`, `win` or `mac`
--                 -- --   -- eclipse.jdt.ls installation            Depending on your system.
--                 -- --
--                 -- --   -- See `data directory configuration` section in the README
--                 --   "-data",
--                 --   workspace_dir,
--                 -- },
--                 cmd = { "/home/void/Github/jdtls/bin/jdtls" },
--
--                 -- This is the default if not provided, you can remove it. Or adjust as needed.
--                 -- One dedicated LSP server & client will be started per unique root_dir
--                 root_dir = require("jdtls.setup").find_root { ".git", "mvnw", "gradlew" },
--
--                 -- Here you can configure eclipse.jdt.ls specific settings
--                 -- See https://github.com/eclipse/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line#initialize-request
--                 -- for a list of options
--                 settings = {
--                   java = {},
--                 },
--                 handlers = {
--                   ["language/status"] = function(_, result)
--                     -- print(result)
--                   end,
--                   ["$/progress"] = function(_, result, ctx)
--                     -- disable progress updates.
--                   end,
--                 },
--               }
--               require("jdtls").start_or_attach(config)
--             end,
--           })
--           return true
--         end,
--       },
--     },
--   },
-- }
return {
  {
    "neovim/nvim-lspconfig",
    dependencies = { "mfussenegger/nvim-jdtls" },
    opts = {
      setup = {
        jdtls = function(_, opts)
          vim.api.nvim_create_autocmd("FileType", {
            pattern = "java",
            callback = function()
              require("lazyvim.util").on_attach(function(_, buffer)
                local mappings = {
                  { "<leader>di", "<Cmd>lua require'jdtls'.organize_imports()<CR>", "Organize Imports" },
                  { "<leader>dt", "<Cmd>lua require'jdtls'.test_class()<CR>", "Test Class" },
                  { "<leader>dn", "<Cmd>lua require'jdtls'.test_nearest_method()<CR>", "Test Nearest Method" },
                  { "<leader>de", "<Esc><Cmd>lua require('jdtls').extract_variable(true)<CR>", "Extract Variable", "v" },
                  { "<leader>de", "<Cmd>lua require('jdtls').extract_variable()<CR>", "Extract Variable" },
                  { "<leader>dm", "<Esc><Cmd>lua require('jdtls').extract_method(true)<CR>", "Extract Method", "v" },
                  { "<leader>cf", "<cmd>lua vim.lsp.buf.formatting()<CR>", "Format" },
                }

                for _, mapping in ipairs(mappings) do
                  local mode = mapping[4] or "n"
                  vim.keymap.set(mode, mapping[1], mapping[2], { buffer = buffer, desc = mapping[3] })
                end
              end)

              local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
              local workspace_dir = "/home/void/.cache/jdtls/workspace/" .. project_name
              
              local config = {
                cmd = { "/home/void/Github/jdtls/bin/jdtls" },
                root_dir = require("jdtls.setup").find_root { ".git", "mvnw", "gradlew" },
                settings = {
                  java = {},
                },
                handlers = {
                  ["language/status"] = function(_, result) end,
                  ["$/progress"] = function(_, result, ctx) end,
                },
              }

              require("jdtls").start_or_attach(config)
            end,
          })
          return true
        end,
      },
    },
  },
}
