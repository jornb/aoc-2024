-- Parse map
local map = {}
for line in io.lines() do
    local row = {}
    for i = 1, #line do
        row[i] = line:sub(i, i)
    end
    table.insert(map, row)
end

function isPartOfComponent(map, x, y, type)
    if x < 1 or x > #map[1] or y < 1 or y > #map then
        return false
    end
    return map[y][x] == type
end

function popConnectedComponent(map, x0, y0)
    local connectedComponent = {
        perimeter = 0,
        coordinates = {}
    }

    if map[y0][x0] == "." then
        return connectedComponent
    end

    local type = map[y0][x0]

    local queue = {
        {x = x0, y = y0}
    }
    while #queue > 0 do
        local current = table.remove(queue)

        -- Chech if already visited
        for _, coordinate in ipairs(connectedComponent.coordinates) do
            if coordinate.x == current.x and coordinate.y == current.y then
                goto continue
            end
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
            else
                connectedComponent.perimeter = connectedComponent.perimeter + 1
            end
        end

        -- Add to connected component
        table.insert(connectedComponent.coordinates, {x = current.x, y = current.y})

        ::continue::
    end

    -- Remove from map
    for _, coordinate in ipairs(connectedComponent.coordinates) do
        map[coordinate.y][coordinate.x] = "."
    end

    return connectedComponent
end

local result = 0

for y = 1, #map do
    for x = 1, #map[y] do
        local c = popConnectedComponent(map, x, y)
        result = result + #c.coordinates * c.perimeter
    end
end

print("The answer is: " .. result)
