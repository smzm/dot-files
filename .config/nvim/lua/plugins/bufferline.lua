return {
    'akinsho/bufferline.nvim',
    dependencies = 'nvim-tree/nvim-web-devicons',
    version = '*',
    event = 'UIEnter',
    opts = {
        options = {
            mode = 'buffers',
            diagnostics = 'nvim_lsp',
        },
    },
}
