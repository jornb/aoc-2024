map = char([]);
moves = char([]);
parseMoves = false;
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
        map = [map; line];
    end
end

function [new_map, new_robot_pos] = shiftBoulders(map, robot_pos, target_position)
    % By default, nothing happened
    new_map = map;
    new_robot_pos = robot_pos;

    direction = target_position - robot_pos;

    % Search for end_of_shift == '.' or '#'
    end_of_shift = target_position;
    while map(end_of_shift(1), end_of_shift(2)) == 'O'
        end_of_shift = end_of_shift + direction;
        c = map(end_of_shift(1), end_of_shift(2));
        if c == '.' || c == '#'
            break;
        end
    end

    % If end_of_shift is not a valid position, return early
    if map(end_of_shift(1), end_of_shift(2)) == '#'
        return;
    end

    % Shift boulders
    while any(end_of_shift != target_position)
        new_map(end_of_shift(1), end_of_shift(2)) = 'O';
        end_of_shift = end_of_shift - direction;
    end

    % Move robot
    new_map(robot_pos(1), robot_pos(2)) = '.';
    new_map(target_position(1), target_position(2)) = '@';
    new_robot_pos = target_position;
end

function [new_map, new_robot_pos] = move(map, robot_pos, move)
    new_robot_pos = robot_pos;
    new_map = map;

    if move == '<'
        target_position = robot_pos - [0, 1];
    elseif move == '>'
        target_position = robot_pos + [0, 1];
    elseif move == '^'
        target_position = robot_pos - [1, 0];
    elseif move == 'v'
        target_position = robot_pos + [1, 0];
    end

    c = map(target_position(1), target_position(2));
    if c == '.'
        % Move robot
        new_map(robot_pos(1), robot_pos(2)) = '.';
        new_map(target_position(1), target_position(2)) = '@';
        new_robot_pos = target_position;
    elseif c == 'O'
        [new_map, new_robot_pos] = shiftBoulders(map, robot_pos, target_position);
    end
end

function [result] = calculateSumOfGps(map)
    result = 0;
    for i = 1:size(map, 1)
        for j = 1:size(map, 2)
            if map(i, j) == 'O'
                result = result + (i-1)*100 + (j-1);
            end
        end
    end
end

[robot_row, robot_col] = find(map == '@');
robot_pos = [robot_row, robot_col];

for i = 1:length(moves)
    [map, robot_pos] = move(map, robot_pos, moves(i));
end

result = calculateSumOfGps(map);
fprintf('The answer is: %d\n', result);