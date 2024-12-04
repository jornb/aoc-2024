import std.algorithm;
import std.array;
import std.conv;
import std.stdio;


bool search_for_xmas(const char[][] lines, int i, int j, int di, int dj) {
    const char[] word = "XMAS";

    for (int k = 0; k < word.length; k++) {
        if (i < 0 || i >= lines.length || j < 0 || j >= lines[i].length) {
            return false;
        }
        if (lines[i][j] != word[k]) {
            return false;
        }
        i += di;
        j += dj;
    }

    return true;
}

void main() {
    auto lines = stdin.byLine.map!(line => line.dup).array;
    int sum = 0;
    foreach (i; 0..lines.length) {
        foreach (j; 0..lines[i].length) {
            if (lines[i][j] == 'X') {
                if (search_for_xmas(lines, to!int(i), to!int(j),  0,  1)) { sum += 1; }
                if (search_for_xmas(lines, to!int(i), to!int(j),  0, -1)) { sum += 1; }
                if (search_for_xmas(lines, to!int(i), to!int(j),  1,  0)) { sum += 1; }
                if (search_for_xmas(lines, to!int(i), to!int(j), -1,  0)) { sum += 1; }
                if (search_for_xmas(lines, to!int(i), to!int(j),  1,  1)) { sum += 1; }
                if (search_for_xmas(lines, to!int(i), to!int(j), -1, -1)) { sum += 1; }
                if (search_for_xmas(lines, to!int(i), to!int(j),  1, -1)) { sum += 1; }
                if (search_for_xmas(lines, to!int(i), to!int(j), -1,  1)) { sum += 1; }
            }
        }
    }
    writeln(i"The answer is: $(sum)");
}
