function pos = mapToSub(mapPos)
    pos = int32([mapPos(1), 1 + (mapPos(2) - 1) * 2]);
end

boulders = int32([]);
blockers = int32([]);
moves = char([]);
parseMoves = false;
mapHeight = 0;
mapWidth = 0;
robotPos = int32([0, 0]);
while ~feof(stdin)
    line = fgetl(stdin);

    if length(line) == 0
        if parseMoves
            break;
        end
        parseMoves = true;
        continue;
    end

    if parseMoves
        moves = [moves line];
    else
        mapWidth = length(line);
        mapHeight = mapHeight + 1;
        for i=1:length(line)
            if line(i) == 'O'
                boulders = [boulders; mapToSub([mapHeight, i])];
            elseif line(i) == '#'
                blockers = [blockers; mapToSub([mapHeight, i])];
            elseif line(i) == '@'
                robotPos = mapToSub([mapHeight, i]);
            end
        end
    end
end

function printMap(boulders, blockers, robotPos, mapHeight, mapWidth)
    map = repmat('.', mapHeight, mapWidth * 2);
    for i=1:size(boulders, 1)
        pos = boulders(i, :);
        map(pos(1), pos(2) + 0) = '[';
        map(pos(1), pos(2) + 1) = ']';
    end
    for i=1:size(blockers, 1)
        pos = blockers(i, :);
        map(pos(1), pos(2) + 0) = '#';
        map(pos(1), pos(2) + 1) = '#';
    end
    map(robotPos(1), robotPos(2)) = '@';
    map
end

function i = getIndex(objects, pos)
    py = pos(1);
    px = pos(2);
    for i=1:size(objects, 1)
        by = objects(i, 1);
        bx = objects(i, 2);
        if by == py && (bx == px || bx == px - 1)
            return;
        end
    end
    i = -1;
end

function b = isOccupied(objects, pos)
    b = getIndex(objects, pos) >= 1;
end

function [newBoulders] = performMove(position, boulders, blockers, delta)
    newBoulders = boulders;

    i = getIndex(boulders, position);
    if i < 1
        return;
    end
    b1 = boulders(i, :);

    % Make space
    if delta(2) == -1
        % Horizontal
        newBoulders = performMove(b1 + delta, newBoulders, blockers, delta);
    elseif delta(2) == 1
        % Horizontal
        newBoulders = performMove(b1 + delta + [0, 1], newBoulders, blockers, delta);
    else
        % Vertical
        b2 = b1 + [0, 1];
        newBoulders = performMove(b1 + delta, newBoulders, blockers, delta);
        newBoulders = performMove(b2 + delta, newBoulders, blockers, delta);
    end

    newBoulders(i, :) = b1 + delta;
end

function b = canMove(position, boulders, blockers, delta)
    b = false;

    if isOccupied(blockers, position)
        return;
    end

    if ~isOccupied(boulders, position)
        b = true;
        return;
    end

    % Horizontal
    if delta(1) == 0
        b = canMove(position + delta, boulders, blockers, delta);
        return;
    end

    % Vertical
    i = getIndex(boulders, position);
    b1 = boulders(i, :);
    b2 = boulders(i, :) + [0, 1];
    b = canMove(b1 + delta, boulders, blockers, delta) && canMove(b2 + delta, boulders, blockers, delta);
end

function [newBoulders, newRobotPos] = tick(boulders, blockers, robotPos, move)
    newRobotPos = robotPos;
    newBoulders = boulders;

    delta = [0, 0];
    if move == '<'
        delta = [0, -1];
    elseif move == '>'
        delta = [0, 1];
    elseif move == '^'
        delta = [-1, 0];
    elseif move == 'v'
        delta = [1, 0];
    end

    % Simple cases
    targetRobotPos = robotPos + delta;
    if isOccupied(blockers, targetRobotPos)
        return;
    end
    if ~isOccupied(boulders, targetRobotPos)
        newRobotPos = targetRobotPos;
        return;
    end
    if ~canMove(targetRobotPos, boulders, blockers, delta)
        return;
    end

    % Make space then move
    newBoulders = performMove(targetRobotPos, boulders, blockers, delta);
    newRobotPos = targetRobotPos;
end

function [result] = calculateSumOfGps(boulders, mapWidth, mapHeight)
    result = 0;
    for i=1:size(boulders, 1)
        pos = boulders(i, :);
        result = result + (pos(1)-1)*100 + (pos(2)-1);
    end
end

%printMap(boulders, blockers, robotPos, mapHeight, mapWidth);

for i=1:length(moves)
    if mod(i, 100) == 0
        fprintf("Progress: %5.1f %%\n", 100*i/length(moves));
    end

    [boulders, robotPos] = tick(boulders, blockers, robotPos, moves(i));
end

%printMap(boulders, blockers, robotPos, mapHeight, mapWidth);

result = calculateSumOfGps(boulders, mapWidth, mapHeight);
fprintf('The answer is: %d\n', result);
