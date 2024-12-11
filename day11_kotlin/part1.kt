fun getNumberOfStonesAfterNBlinks(stone_number: Long, num_blinks: Long): Int {
    if (num_blinks <= 0) {
        return 1
    }

    if (stone_number == 0.toLong()) {
        return getNumberOfStonesAfterNBlinks(1, num_blinks - 1)
    }

    val s = stone_number.toString()
    if (s.length % 2 == 0) {
        val s1 = s.substring(0, s.length / 2)
        val s2 = s.substring(s.length / 2)
        val n1 = s1.toLong()
        val n2 = s2.toLong()
        return getNumberOfStonesAfterNBlinks(n1, num_blinks - 1) + getNumberOfStonesAfterNBlinks(n2, num_blinks - 1)
    }

    return getNumberOfStonesAfterNBlinks(stone_number * 2024, num_blinks - 1)
}

fun main() {
    val line = readln()
    val numbers = line.split(" ").map { it.toLong() }

    var sum = 0
    for (number in numbers) {
        sum += getNumberOfStonesAfterNBlinks(number, 25)
    }

    println("The answer is: $sum")
}