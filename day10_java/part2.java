import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Scanner;
import java.util.Set;

class Coordinates {
    public int x;
    public int y;
}

public class A {
    public static boolean isInsideMap(List<List<Integer>> map, int x, int y) {
        return x >= 0 && x < map.get(0).size() && y >= 0 && y < map.size();
    }

    public static int findDistinctPaths(List<List<Integer>> map, int x0, int y0) {
        // Unreachable
        if (!isInsideMap(map, x0, y0)) {
            return 0;
        }

        // Reached the top!
        int h = map.get(y0).get(x0);
        if (h == 9) {
            return 1;
        }

        int result = 0;
        if (isInsideMap(map, x0 - 1, y0) && map.get(y0).get(x0 - 1) == h + 1) {
            result += findDistinctPaths(map, x0 - 1, y0);
        }

        if (isInsideMap(map, x0 + 1, y0) && map.get(y0).get(x0 + 1) == h + 1) {
            result += findDistinctPaths(map, x0 + 1, y0);
        }

        if (isInsideMap(map, x0, y0 - 1) && map.get(y0 - 1).get(x0) == h + 1) {
            result += findDistinctPaths(map, x0, y0 - 1);
        }

        if (isInsideMap(map, x0, y0 + 1) && map.get(y0 + 1).get(x0) == h + 1) {
            result += findDistinctPaths(map, x0, y0 + 1);
        }

        return result;
    }

    public static void main(String[] args) {
        List<List<Integer>> map = new ArrayList<>();
        List<Coordinates> startPositions = new ArrayList<>();
        
        Scanner scanner = new Scanner(System.in);
        int y = 0;
        while (scanner.hasNextLine()) {
            String line = scanner.nextLine();
            List<Integer> heights = new ArrayList<>();
            int x = 0;
            for (char ch : line.toCharArray()) {
                if (Character.isDigit(ch)) {
                    int n = Character.getNumericValue(ch);
                    heights.add(n);

                    if (n == 0) {
                        Coordinates c = new Coordinates();
                        c.x = x;
                        c.y = y;
                        startPositions.add(c);
                    }
                }
                x++;
            }
            map.add(heights);
            y++;
        }        
        scanner.close();

        int sum = 0;
        for (Coordinates c : startPositions) {
            sum += findDistinctPaths(map, c.x, c.y);
        }
        
        System.out.println("The answer is: " + sum);
    }
}