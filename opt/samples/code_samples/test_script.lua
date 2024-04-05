function main()
    local f = io.open('four_strings.txt', 'r')
    local txt_list = {}
    for line in f:lines() do
        table.insert(txt_list, line)
    end
    f:close()
    local ans = txt_list[math.random(1, #txt_list)]
    -- print(ans)
    while true do
        print('4 letters >> ')
        local in_txt = io.read()
        if #in_txt ~= 4 then
            print('incorrect input')
            return
        end

        local res = ''
        for i=1, 4, 1 do
            local char = in_txt:sub(i, i)
            if ans:sub(i, i) == char then
                res = res..'o'
            elseif string.find(ans, char) ~= nil then
                res = res..'~'
            else
                res = res..'x'
            end
        end
        print('----')
        print(res)
        if res == 'oooo' then
            print('Great!')
            break
        end
    end
end

main()
