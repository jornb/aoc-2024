import 'dart:io';

bool isKey(String firstLine) {
    return firstLine.startsWith(".");
}

int count(List<String> keyOrLock, int index, String character) {
    int count = 0;
    for (String row in keyOrLock) {
        if (row[index] == character) {
            count++;
        }
    }
    return count;
}

List<int> getPinHeights(List<String> keyOrLock) {
    List<int> peaks = [];
    for (int i = 0; i < keyOrLock[0].length; i++) {
        peaks.add(count(keyOrLock, i, "#") - 1);
    }
    return peaks;
}

bool isMatch(List<int> key, List<int> lock) {
    for (int i = 0; i < key.length; i++) {
        if (lock[i] + key[i] > 5) {
            return false;
        }
    }
    return true;
}

void main() {
    List<List<int>> locks = [];
    List<List<int>> keys = [];

    List<String> current = [];
    while (true) {
        String? line = stdin.readLineSync();
        if (line == null)
            break;
        
        if (line.isEmpty)
            continue;
        
        current.add(line);

        if (current.length == 7) {
            var pins = getPinHeights(current);
            if (isKey(current[0])) {
                keys.add(pins);
            } else {
                locks.add(pins);
            }
            current = [];
        }
    }

    int sum = 0;
    for (var lock in locks) {
        for (var key in keys) {
            if (isMatch(key, lock)) {
                print("Lock $lock and key $key: all columns fit");
                sum++;
            } else {
                print("Lock $lock and key $key: not all columns fit");
            }
        }
    }

    print("The answer is: $sum");
}