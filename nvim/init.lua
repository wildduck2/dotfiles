require("thevimagen")
require("configs")


---@param a number
---@param b number
---@function singInWithUserName(a, b)
function singInWithUserName(a, b)
    return a + b
end

---@class Tuple
---@field public userName number
local Tuple = {
    userName = 123
}


---@param name string
---@function getResolved(res)
function getName(name)
    print(name.find('n', name))
end

getName('name')
