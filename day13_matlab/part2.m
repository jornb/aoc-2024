function [s] = getMinimumCost(xa, ya, xb, yb, xp, yp)
    s = uint64(0);

    d = xa*yb - xb*ya;
    if d == 0
        return;
    end

    an = yb*xp - xb*yp;
    bn = xa*yp - ya*xp;

    if mod(an, d) ~= 0 || mod(bn, d) ~= 0
        return;
    end

    s = 3*an/d + bn/d;
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
        answer = answer + getMinimumCost(xa, ya, xb, yb, 10000000000000+xp, 10000000000000+yp);
    end
end

fprintf('The answer is: %d\n', answer);
