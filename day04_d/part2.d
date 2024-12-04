import std.algorithm;
import std.array;
import std.conv;
import std.stdio;


bool is_char(const char[][] lines, int i, int j, char target) {
    if (i < 0 || i >= lines.length || j < 0 || j >= lines[i].length) {
        return false;
    }
    if (lines[i][j] != target) {
        return false;
    }
    return true;
}

bool is_mas(const char[][] lines, int i, int j, int di, int dj) {
    return (is_char(lines, i - di, j - dj, 'M') && is_char(lines, i, j, 'A') && is_char(lines, i + di, j + dj, 'S')) ||
           (is_char(lines, i - di, j - dj, 'S') && is_char(lines, i, j, 'A') && is_char(lines, i + di, j + dj, 'M'));
}

bool check(const char[][] lines, int i, int j) {
    return is_mas(lines, i, j, 1, 1) && is_mas(lines, i, j, 1, -1);
}

void main() {
    auto lines = stdin.byLine.map!(line => line.dup).array;
    int sum = 0;
    foreach (i; 0..lines.length) {
        foreach (j; 0..lines[i].length) {
            if (check(lines, to!int(i), to!int(j))) {
                sum += 1;
            }
        }
    }
    writeln(i"The answer is: $(sum)");
}
