Element = {
    point = {},
    active,
    id = 0,
    expiration = 0,
    createdAt = 0
}

function Element:new(point, active, id, iter)
    local element = {}
    setmetatable(element, self)
    self.__index = self
    element.point = point
    element.active = active
    element.id = id
    element.expiration = 300
    element.createdAt = iter

    return element
end

local i, j, point = ...

local count = 0
local counterId = 0
local counterRed = 0
local counterGreen = 0
local counterBlue = 0
local threshold = 3

print(i .. "    " .. j .."  "..point.id.. "\n")

