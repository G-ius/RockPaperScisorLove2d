local lg = love.graphics
local lk = love.keyboard
local ww = lg.getWidth()
local wh = lg.getHeight()
local boderExpessure
local borderedLeftWidth
local borderedDownHeight
local borderedUpperHeight
local borderedRightWidth
local playgroundWidth
local playgroundHeigth
local points
local renderedPoints
local iterations
local antiterations
local reverse
local freeToIterate
local result
local threshold

Element = {
    point = {},
    id = 0,
    expiration = 0,
    iterable = 0,
    createdAt = 0,
    age = 0
}

function Element:new(point, id, iterable)
    local element = {}
    setmetatable(element, self)
    self.__index = self
    element.point = point
    element.iterable = iterable
    element.id = id
    element.expiration = 300
    element.createdAt = iter
    return element
end

function love.load()
    points = {}
    renderedPoints = {}
    borderExpessure = 1
    iterations = 0
    antiterations = 0
    freeToIterate = 0
    threshold = 4
    reverse = false
    borderedLeftWidth = borderExpessure
    borderedDownHeight = wh - borderExpessure
    borderedUpperHeight = borderExpessure
    borderedRightWidth = ww - borderExpessure
    playgroundWidth = ww - (2 * borderExpessure)
    playgroundHeigth = wh - (2 * borderExpessure)
    generateNoise()
    -- resetPoints()
end

function love.update(dt)
    -- manageMouse()
    -- iteratePoints()
    -- iterate()
end

function love.draw()
    -- lg.setColor(0, 0, 0)
    lg.points(renderedPoints)
end

function manageMouse()
    if love.mouse.isDown(1) then
        if freeToIterate < 1 then
            freeToIterate = 2
        else
            local x, y = love.mouse.getPosition()
            if x > 30 and y > 30 and x < playgroundWidth - 30 and y < playgroundHeigth - 30 then
                for i = x - 30, x + 31 do
                    for j = y - 30, y + 31 do
                        points[i][j] = Element:new({i, j, 1, 0, 0}, 1, 0, 0)
                    end
                end
            end
        end
    end
end

function iterate()

    if freeToIterate > 1 then
        count = #renderedPoints
        for i = 0, count do
            renderedPoints[i] = nil
        end
        iteratePoints()
    end
end

function resetPoints()
    count = #renderedPoints
    for i = 0, count do
        table.remove(renderedPoints, i)
    end

    for i = 0, playgroundWidth do
        points[i] = {}
        for j = 0, playgroundHeigth do
            number = love.math.random(0, 2)
            if number == 0 then
                points[i][j] = Element:new({i + borderExpessure, j + borderExpessure, 1, 0, 0}, 1, number, 0)
            elseif number == 1 then
                points[i][j] = Element:new({i + borderExpessure, j + borderExpessure, 0, 1, 0}, 1, number, 0)
            elseif number == 2 then
                points[i][j] = Element:new({i + borderExpessure, j + borderExpessure, 0, 0, 1}, 1, number, 0)
            end

            table.insert(renderedPoints, points[i][j].point)
        end
    end
end

function calculateResult(reorderedPoints, i, j)

    local count = 0
    local counterId = 0
    local counterRed = 0
    local counterGreen = 0
    local counterBlue = 0

    local threshold = 3

    if points[i][j].id == 0 then
        counterId = 1
        counterGreen = 1

    end

    if points[i][j].id == 1 then
        counterId = 2
        counterBlue = 1

    end

    if points[i][j].id == 2 then
        counterId = 0
        counterRed = 1

    end

    if points[i - 1][j].id == counterId then
        count = count + 1
    end
    if points[i][j - 1].id == counterId then
        count = count + 1
    end
    if points[i - 1][j - 1].id == counterId then
        count = count + 1
    end
    if points[i + 1][j + 1].id == counterId then
        count = count + 1
    end
    if points[i + 1][j].id == counterId then
        count = count + 1
    end
    if points[i][j + 1].id == counterId then
        count = count + 1
    end
    if points[i + 1][j - 1].id == counterId then
        count = count + 1
    end
    if points[i - 1][j + 1].id == counterId then
        count = count + 1
    end

    if count >= threshold then
        reorderedPoints[i][j] = Element:new({i + borderExpessure, j + borderExpessure, counterRed, counterGreen,
                                             counterBlue}, 1, counterId, iterations)
    else
        reorderedPoints[i][j] = points[i][j]

    end
    table.insert(renderedPoints, reorderedPoints[i][j].point)

end

function iteratePoints()
    local start = love.timer.getTime()
    iterations = iterations + 1
    local reorderedPoints = {}

    for i = 0, playgroundWidth do
        reorderedPoints[i] = {}
        for j = 0, playgroundHeigth do
            reorderedPoints[i][j] = {}
        end
    end

    for i = 1, playgroundWidth - 1 do
        for j = 1, playgroundHeigth - 1 do
            calculateResult(reorderedPoints, i, j)
        end
    end

    for i = 0, playgroundWidth do
        points[i] = {}
        for j = 0, playgroundHeigth do
            points[i][j] = reorderedPoints[i][j]
        end
    end
    print(love.timer.getTime() - start)
end

function iterateCave()

    for c = 0, 5 do
        print(c)
        local reorderedPoints = {}

        for i = 0, playgroundWidth do
            reorderedPoints[i] = {}
            for j = 0, playgroundHeigth do
                verifyNeighbours(reorderedPoints, i, j)
            end
        end

        for i = 0, playgroundWidth do
            points[i] = {}
            for j = 0, playgroundHeigth do

                points[i][j] = reorderedPoints[i][j]
            end
        end

    end

    count = #renderedPoints
    for i = 0, count do
        table.remove(renderedPoints, i)
    end

    for i = 0, playgroundWidth do
        for j = 0, playgroundHeigth do
            table.insert(renderedPoints, points[i][j].point)
        end
    end

end

function verifyNeighbours(reorderedPoints, i, j)
    local counter = 0
    for k = -1, 1 do
        for n = -1, 1 do
            if k + n ~= 0 then
                if i + k >= 0 and n + j >= 0 and i + k <= playgroundWidth and j + n <= playgroundHeigth then
                    if points[i + k][j + n].iterable > 0 then
                        counter = counter + 1
                    end
                end
            end
        end
    end
    if counter >= threshold then
        reorderedPoints[i][j] = Element:new({i + borderExpessure, j + borderExpessure, 0, 0, 0}, 9, 0)
    end
    if counter < threshold then
        reorderedPoints[i][j] = Element:new({i + borderExpessure, j + borderExpessure, 1, 1, 1}, 9, 1)
    end
end

function generateNoise()

    for i = 0, playgroundWidth + 1 do
        points[i] = {}
        for j = 0, playgroundHeigth + 1 do
            local magicNumber = math.random(0, 1)
            points[i][j] = Element:new({i + borderExpessure, j + borderExpessure, 1 - magicNumber, 1 - magicNumber,
                                        1 - magicNumber}, 9, magicNumber)
        end
    end
    iterateCave()
end
