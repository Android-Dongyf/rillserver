--
-- Created by IntelliJ IDEA.
-- User: junping
-- Date: 2016/6/14
-- Time: 18:42
-- To change this template use File | Settings | File Templates.
--

local TabToStr = TabToStr
local math = math
local pairs = pairs
local ipairs = ipairs
local type = type
local table = table
local sformat = string.format
local Logger = DEBUG
local tostring = tostring


-- convert table to str
local function __tabToStr(tab, is)
    if tab == nil then
        return nil
    end
    local result = "{"

    for k, v in pairs(tab) do
        if type(k) == "number" then
            if type(v) == "table" then
                result = sformat("%s[%d]=%s,", result, k, __tabToStr(v, is))
            elseif type(v) == "number" then
                result = sformat("%s[%d]=%s,", result, k, tostring(v))
            elseif type(v) == "string" then
                result = sformat("%s[%d]=%q,", result, k, v)
            elseif type(v) == "boolean" then
                result = sformat("%s[%d]=%s,", result, k, tostring(v))
            else
                if is then
                    result = sformat("%s[%d]=%q,", result, k, type(v))
                else
                    error("the type of value is a function or userdata")
                end
            end
        else
            if type(v) == "table" then
                result = sformat("%s['%s']=%s,", result, k, __tabToStr(v, is))
            elseif type(v) == "number" then
                result = sformat("%s['%s']=%s,", result, k, tostring(v))
            elseif type(v) == "string" then
                result = sformat("%s['%s']=%q,", result, k, v)
            elseif type(v) == "boolean" then
                result = sformat("%s['%s']=%s,", result, k, tostring(v))
            else
                if is then
                    result = sformat("%s['%s']=%q,", result, k, type(v))
                else
                    error("the type of value is a function or userdata")
                end
            end
        end
    end
    result = result .. "}"
    return result
end


--module("Table", package.seeall)
local Table = {}

-- 把table 转化成 string
Table.toString = TabToStr or __tabToStr

function Table.print(tb, t, vname, deep)
    deep = deep or 0
    if deep >= 20 then return end
    local printx = function(k, v, c)
        c = c or ''
        local str
        if v ~= nil then
            str = k .. ' = ' .. tostring(v) .. c
        else
            str = k
        end
        local pre = ''
        for i = 1, deep do
            pre = pre .. '   '
        end
        str = pre .. str
        Logger.info(str)
    end
    if vname ~= nil then
        printx(vname , "{")
    else
        printx("{")
    end

    for key, value in pairs(tb) do
        key = "['" .. key .. "']"
        local ty = type(value)
        if ty == "table" then
            print(value, t, key, deep + 1)
        elseif ty == 'function' then
            printx('   ' .. key, '(function)', ',')
        else
            printx('   ' .. key, value, ',')
        end
    end
    printx("},")
end

--[[
--打印table到控制台
 ]]
function Table.printConsole(tb)
    print(tb, 'console')
end

--[[
--返回table是否为空
 ]]
function Table.isEmpty(tab)
    return (tab == nil) or (next(tab) == nil)
end

--[[
--检测table是否存在某个值
 ]]
function Table.isExistValue(tab, value)
    for _, v in pairs(tab or {}) do
        if v == value then
            return true
        end
    end
    return false
end

--[[
--判断两个Table的元素是否相交（有相同的元素）
 ]]
function Table.isCrossing(tb1, tb2)
    for _, v in pairs(tb1) do
        if isExistValue(tb2, v) then
            return true
        end
    end
    return false
end

--[[
--获得数组的下标
 ]]
function Table.getIndex(tb, value)
    for i, v in ipairs(tb) do
        if v == value then
            return i
        end
    end
    return 0
end

--[[
--检测table是否存在某个键
 ]]
function Table.isExistKey(tab, key)
    for k, v in pairs(tab) do
        if k == key then
            return true
        end
    end
    return false
end

--[[
--删除列表中指定的所有项
 ]]
function Table.removeItemAll(tab, item)
    for i = #tab, 1, -1 do
        if tab[i] == item then
            table.remove(tab, i)
        end
    end
end


--[[
--从左删除列表中指定的一项
 ]]
function Table.removeItemL(tab, item)
    for i = 1, #tab do
        if tab[i] == item then
            table.remove(tab, i)
            return i
        end
    end
    return 0
end


--[[
--从右删除列表中指定的一项
 ]]
function Table.removeItemR(tab, item)
    for i = #tab, 1, -1 do
        if tab[i] == item then
            table.remove(tab, i)
            return i
        end
    end
    return 0
end



--[[
--返回table的长度
 ]]
function Table.length(tab)
    local count = 0
    for _, v in pairs(tab) do
        count = count + 1
    end
    return count
end

--将一个数组内元素随机洗牌
function Table.shuffle(tab)
    local len = #tab
    for i = len, 1, -1 do
        local j = math.random(1, len)
        tab[i], tab[j] = tab[j], tab[i]
    end

    return tab
end


--深复制一个table，把tb插入到ta里面，只插入和修改，不改变ta其它本来就有的值
function Table.deepcopy(ta, tb, nofunc)
    nofunc = nofunc or 0
    if type(ta) ~= "table" or type(tb) ~= "table" then return end
    for i, v in pairs(tb) do
        local t = type(v)
        if t == "table" then
            if not ta[i] then ta[i] = {} end
            deepcopy(ta[i], v, nofunc)
        elseif t == 'function' then
            if nofunc == 0 then
                ta[i] = v
            end
        else
            ta[i] = v
        end
    end
end


--浅复制一个table，把tb插入到ta里面，只插入ta里面没有的项，不修改已有的值
function Table.lightCopy(ta, tb, nofunc)
    nofunc = nofunc or 0
    if type(ta) ~= "table" or type(tb) ~= "table" then return end

    for i, v in pairs(tb) do
        local t = type(v)
        if t == "table" then
            if not ta[i] then ta[i] = {} end
            lightCopy(ta[i], v, nofunc)
        elseif not ta[i] then
            if t == 'function' then
                if nofunc == 0 then
                    ta[i] = v
                end
            else
                ta[i] = v
            end
        end
    end
end


--[[
--合并两个Table数组
 ]]
function Table.joinArray(ta, tb)
    if type(ta) ~= "table" or type(tb) ~= "table" then return end
    for _, v in ipairs(tb) do
        table.insert(ta, v)
    end
    return ta
end

-- 合并两个map
function Table.joinMap(ta, tb)
    if type(ta) ~= "table" or type(tb) ~= "table" then return end
    for k, v in pairs(tb) do
        ta[k] = v
    end
    return ta
end

-- 截取一个数组的一部分
-- @index 起始序号（<0表示从后往前算）
-- @length 截取长度（nil表示后面所有）
function Table.slice( tb, index, length )
    local n = #tb
    local part = {}
    if n > 0 then
        index = math.max(1, index < 0 and n + index + 1 or index)
        length = length and math.min(n - index + 1, length) or n - index + 1
        for i = 1, length do
            part[i] = tb[index + i - 1]
        end
    end
    return part
end


--比较两个table，相同返回true，不相同返回false
function Table.compare(ta, tb)
    if type(ta) ~= "table" or type(tb) ~= "table" then return false end

    for i, v in pairs(ta) do
        if type(v) == "table" then
            if tb[i] then
                local rst = compare(v, tb[i])
                if not rst then return false end
            end
        else
            if tb[i] ~= v then return false end
        end
    end

    for i, v in pairs(tb) do
        if type(v) == "table" then
            if ta[i] then
                local rst = compare(v, ta[i])
                if not rst then return false end
            end
        else
            if ta[i] ~= v then return false end
        end
    end

    return true
end

function Table.keys(tb)
    local rt = {}
    for k, _ in pairs(tb) do
        table.insert(rt, k)
    end
    return rt
end

function Table.values(tb)
    local rt = {}
    for _, v in pairs(tb) do
        table.insert(rt, v)
    end
    return rt
end

function Table.fields(tb, field)
    local rt = {}
    for _, v in pairs(tb) do
        table.insert(rt, v[field])
    end
    return rt
end

function Table.keyFields(tb, field)
    local rt = {}
    for k, v in pairs(tb) do
        rt[k] = v[field]
    end
    return rt
end

function Table.map(tb, func)
    local rt = {}
    for k, v in pairs(tb) do
        rt[k] = func(v)
    end
    return rt
end

function Table.imap(tb, func)
    local rt = {}
    for i, v in ipairs(tb) do
        rt[i] = func(v)
    end
    return rt
end

function Table.copy(tb)
    local rt = {}
    for k, v in pairs(tb) do
        rt[k] = v
    end
    return rt
end

function Table.icopy(tb)
    local rt = {}
    for i, v in ipairs(tb) do
        rt[i] = v
    end
    return rt
end

function Table.revert(tb)
    local rt = {}
    local n = #tb + 1
    for i, v in ipairs(tb) do
        rt[n - i] = v
    end
    return rt
end

function Table.clone(tb)
    if type(tb) ~= "table" then return end

    local rt = {}
    for k, v in pairs(tb) do
        if type(v) == "table" then
            rt[k] = clone(v)
        else
            rt[k] = v
        end
    end

    return rt
end

function Table.free(t)
    local k,v = next(t)
    while k do
        t[k] = nil
        k,v = next(t)
    end
    t.tag = "freed table"
end


function Table.cloneData(tb, pattens, layer)
    if type(tb) ~= "table" then return false end
    pattens = pattens or {}
    layer = layer or 0

    assert(layer <= 10, "cloneData layer overflow")

    local rt = {}
    for i, v in pairs(tb) do
        local pass = true
        for _, ptn in ipairs(pattens) do
            if string.match(i, ptn) then
                pass = false
                break
            end
        end

        if pass then
            if type(v) == "table" then
                rt[i] = Table.cloneData(v, pattens, layer + 1)
            else
                local ty = type(v)
                if ty == "number" or ty == "string" then
                    rt[i] = v
                end
            end
        end
    end

    return rt
end



--[[产生一个[a, b]拿count个不重复的随机数组
例如:getRandomArray(1, 100, 4) 可能返回 {100, 44, 77, 1}
]]
function Table.getRandomArray(a, b, count)
    if (b < a) or (count > b - a + 1) then return end

    local arr = {}
    local rt = {}
    for i = a, b do table.insert(arr, i) end --生成一个[a, b]的数组

    local len = #arr
    for i = 1, count do
        if i < len then
            local j = math.random(i + 1, len)
            local tmp = arr[i]
            arr[i] = arr[j]
            arr[j] = tmp
        end

        table.insert(rt, arr[i])
    end

    return rt
end

--pblist概率权重表，如{10 ，30 ，40} ，count生成的随机序列个数,返回随机序列
function Table.getRandArrayEx(pblist, count)
    local total = 0
    for k, v in pairs(pblist) do
        total = total + v
    end

    local tb = {}
    for i = 1, count do
        local s = math.random(1, total)
        for k, v in pairs(pblist) do
            if s <= v then
                table.insert(tb, k)
                break
            else
                s = s - v
            end
        end
    end
    return tb
end

return Table
