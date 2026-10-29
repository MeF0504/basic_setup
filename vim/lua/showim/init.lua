
local M = {}

function M.show(file, height, width)
    local row = 2
    local col = vim.api.nvim_get_option_value('columns', {})/4
    local id = vim.ui.img.set(vim.fn.readblob(file),
     { row=row, col=col, width=width, height=height, zindex=50 }
    )
    M.id = id
    print(":call meflib#image#close() to close the image.")
end

function M.close()
    vim.ui.img.del(M.id)
    M.id = nil
end

return M
