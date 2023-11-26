local M = {
  "nanotee/sqls.nvim",
  commit = "4b1274b5b44c48ce784aac23747192f5d9d26207",
  event = "BufReadPre",
  dependencies = {
    {
      "neovim/nvim-lspconfig",
      commit = "649137cbc53a044bffde36294ce3160cb18f32c7",
    },
  },
}
  
function M.config()
 require('lspconfig').sqls.setup{
    settings = {
    sqls = {
      connections = {
        {
          driver = 'postgresql',
          dataSourceName = 'host=127.0.0.1 port=5432 user=postgres password=postgres dbname=postgres sslmode=disable',
        },
      },
    },
  },

  on_attach = function(client, bufnr)
      require('sqls').on_attach(client, bufnr)
  end
  }
end

  return M

