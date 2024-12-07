package main

import (
    "bufio"
    "fmt"
    "os"
    "strconv"
    "strings"
)

func solve(target int, numbers []int, accumulator int, index int) bool {
    if (accumulator > target) {
        return false;
    }

    if (index == len(numbers)) {
        return accumulator == target;
    }
    
    n := numbers[index];
    return solve(target, numbers, accumulator + n, index + 1) || solve(target, numbers, accumulator * n, index + 1);
}

func main() {
    scanner := bufio.NewScanner(os.Stdin)
    result := 0

    for scanner.Scan() {
        line := scanner.Text()

        // Parse
        parts := strings.Split(line, ":")
        target, _ := strconv.Atoi(parts[0])
        numbers_str := strings.Fields(parts[1])
        numbers := make([]int, len(numbers_str))
        for i, numStr := range numbers_str {
            num, _ := strconv.Atoi(numStr)
            numbers[i] = num
        }

        if (solve(target, numbers, numbers[0], 1)) {
            result += target;
        }
    }

    fmt.Printf("The answer is is %d\n", result)
}
