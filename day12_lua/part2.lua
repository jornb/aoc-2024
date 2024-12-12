-- Parse map
local map = {}
for line in io.lines() do
    local row = {}
    for i = 1, #line do
        row[i] = line:sub(i, i)
    end
    table.insert(map, row)
end
local HEIGHT=#map
local WIDTH=#map[1]

function isInsideMap(x, y)
    return x >= 1 and x <= WIDTH and y >= 1 and y <= HEIGHT
end

function isPartOfComponent(map, x, y, type)
    if not isInsideMap(x, y) then
        return false
    end
    return map[y][x] == type
end

function findCoordinate(coordinates, x, y)
    for i, coordinate in ipairs(coordinates) do
        if coordinate.x == x and coordinate.y == y then
            return i
        end
    end
    return nil
end

function containsCoordinate(coordinates, x, y)
    return findCoordinate(coordinates, x, y) ~= nil
end

function popConnectedComponent(map, x0, y0)
    local coordinates = {}

    if map[y0][x0] == "." then
        return coordinates
    end
    type = map[y0][x0]

    local queue = {
        {x = x0, y = y0}
    }
    while #queue > 0 do
        local current = table.remove(queue)

        -- Chech if already visited
        if containsCoordinate(coordinates, current.x, current.y) then
            goto continue
        end

        neighbors = {
            {x = current.x + 1, y = current.y},
            {x = current.x - 1, y = current.y},
            {x = current.x, y = current.y + 1},
            {x = current.x, y = current.y - 1}
        }

        for _, neighbor in ipairs(neighbors) do
            if isPartOfComponent(map, neighbor.x, neighbor.y, type) then
                table.insert(queue, neighbor)
            end
        end

        -- Add to connected component
        table.insert(coordinates, {x = current.x, y = current.y})

        ::continue::
    end

    -- Remove from map
    for _, coordinate in ipairs(coordinates) do
        map[coordinate.y][coordinate.x] = "."
    end

    return coordinates
end

function getCoordinatesRequiringFenceInDirection(coordinates, direction)
    local result = {}
    for _, coordinate in ipairs(coordinates) do
        local x = coordinate.x + direction.x
        local y = coordinate.y + direction.y

        if not isInsideMap(x, y) or not containsCoordinate(coordinates, x, y) then
            table.insert(result, coordinate)
        end
    end
    return result
end

function popConnected(coordinates, neighborDirections)
    if #coordinates == 0 then
        return {}
    end

    local current = table.remove(coordinates)
    local tails = {current}
    local result = {}
    while #tails > 0 do
        local tail = table.remove(tails)
        table.insert(result, tail)

        for _, direction in ipairs(neighborDirections) do
            local x = tail.x + direction.x
            local y = tail.y + direction.y
            local i = findCoordinate(coordinates, x, y)
            if i ~= nil then
                table.remove(coordinates, i)
                table.insert(tails, {x = x, y = y})
            end
        end
    end

    return result
end

function getConnectedFences(coordinates, neighborDirections)
    result = {}
    while #coordinates > 0 do
        local connected = popConnected(coordinates, neighborDirections)
        if #connected > 0 then
            table.insert(result, connected)
        end
    end
    return result
end

function countRequiredFences(coordinates)
    local cases = {
        { dir={x =  0, y = -1}, neighbors={{x = 1, y = 0}, {x = -1, y =  0}} },
        { dir={x =  0, y =  1}, neighbors={{x = 1, y = 0}, {x = -1, y =  0}} },
        { dir={x = -1, y =  0}, neighbors={{x = 0, y = 1}, {x =  0, y = -1}} },
        { dir={x =  1, y =  0}, neighbors={{x = 0, y = 1}, {x =  0, y = -1}} }
    }

    local sum = 0
    for _, c in ipairs(cases) do
        local edgeCoordinates = getCoordinatesRequiringFenceInDirection(coordinates, c.dir)
        local fences = getConnectedFences(edgeCoordinates, c.neighbors)
        sum = sum + #fences
    end
    return sum
end

local answer = 0
for y = 1, #map do
    for x = 1, #map[y] do
        local c = popConnectedComponent(map, x, y)
        answer = answer + #c * countRequiredFences(c)
    end
end

print("The answer is: " .. answer)
