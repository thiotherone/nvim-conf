return {
  {
    "mfussenegger/nvim-jdtls",
    ft = { "java" },  -- Only load for Java files
    config = function()
      local jdtls = require("jdtls")

      -- Set up workspace for current project
      local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
      local workspace_dir = "/home/void/.workspace/" .. project_name

      -- Configure the jdtls server command and options
      local config = {
        cmd = {
          "java",  -- Ensure 'java' is in your PATH or provide the full path here
          "-javaagent:/home/void/.local/share/java/lombok.jar",
          "-Declipse.application=org.eclipse.jdt.ls.core.id1",
          "-Dosgi.bundles.defaultStartLevel=4",
          "-Declipse.product=org.eclipse.jdt.ls.core.product",
          "-Dlog.protocol=true",
          "-Dlog.level=ALL",
          "-Xms1g",
          "--add-modules=ALL-SYSTEM",
          "--add-opens",
          "java.base/java.util=ALL-UNNAMED",
          "--add-opens",
          "java.base/java.lang=ALL-UNNAMED",
          "-jar",
          vim.fn.glob("/home/void/Github/jdtls/plugins/org.eclipse.equinox.launcher_1.6.400.v20210924-0641.jar"),
          "-configuration",
          "/home/void/Github/jdtls/config_linux",
          "-data",
          workspace_dir,
        },

        -- Define the root directory for jdtls
        root_dir = jdtls.setup.find_root({ ".git", "mvnw", "gradlew" }),

        -- Java-specific settings
        settings = {
          java = {},
        },

        -- Handlers (optional; disable unwanted status updates)
        handlers = {
          ["language/status"] = function(_, result)
            -- Optionally handle the status result
          end,
          ["$/progress"] = function(_, result, ctx)
            -- Optionally handle the progress result
          end,
        },

        -- Optional initialization options for the language server
        init_options = {
          bundles = {},  -- Set any bundles for Java debugging, if needed
        },
      }

      -- Keymaps for Java LSP functions
      local function on_attach(client, bufnr)
        local opts = { buffer = bufnr, desc = "" }
        vim.keymap.set("n", "<leader>di", "<Cmd>lua require'jdtls'.organize_imports()<CR>", opts)
        vim.keymap.set("n", "<leader>dt", "<Cmd>lua require'jdtls'.test_class()<CR>", opts)
        vim.keymap.set("n", "<leader>dn", "<Cmd>lua require'jdtls'.test_nearest_method()<CR>", opts)
        vim.keymap.set("v", "<leader>de", "<Esc><Cmd>lua require'jdtls'.extract_variable(true)<CR>", opts)
        vim.keymap.set("n", "<leader>de", "<Cmd>lua require'jdtls'.extract_variable()<CR>", opts)
        vim.keymap.set("v", "<leader>dm", "<Esc><Cmd>lua require'jdtls'.extract_method(true)<CR>", opts)
        vim.keymap.set("n", "<leader>cf", "<Cmd>lua vim.lsp.buf.format { async = true }<CR>", opts)
      end

      -- Start or attach jdtls with the specified config and `on_attach`
      jdtls.start_or_attach(vim.tbl_extend("keep", config, { on_attach = on_attach }))
    end,
  },
}
