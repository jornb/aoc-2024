% Brute force solution to differentiate from part 2
function [s] = getMinimumCost(xa, ya, xb, yb, xp, yp)
    s = 0;
    found = false;

    for a = 0:100
        for b = 0:100
            if a*xa + b*xb == xp && a*ya + b*yb == yp
                if ~found || 3*a + b < s
                    s = 3*a + b;
                    found = true;
                end
            end
        end
    end
end

answer = 0;
xa=0;
ya=0;
xb=0;
yb=0;
while ~feof(stdin)
    line = fgetl(stdin);

    coords = sscanf(line, 'Button A: X+%d, Y+%d');
    if length(coords) > 0
        xa = coords(1);
        ya = coords(2);
    end

    coords = sscanf(line, 'Button B: X+%d, Y+%d');
    if length(coords) > 0
        xb = coords(1);
        yb = coords(2);
    end

    coords = sscanf(line, 'Prize: X=%d, Y=%d');
    if length(coords) > 0
        coords = sscanf(line, 'Prize: X=%d, Y=%d');
        xp = coords(1);
        yp = coords(2);
        answer = answer + getMinimumCost(xa, ya, xb, yb, xp, yp);
    end
end

fprintf('The answer is: %d\n', answer);
