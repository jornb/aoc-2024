import java.math.BigInteger

fun getNumberOfStonesAfterNBlinks(
    memo: MutableMap<Pair<Long, Int>, BigInteger>,
    stoneNumber: Long,
    numBlinks: Int
): BigInteger {
    if (numBlinks <= 0) {
        return BigInteger.ONE
    }

    val state = Pair(stoneNumber, numBlinks)
    memo[state]?.let {
        return it
    }

    if (stoneNumber == 0.toLong()) {
        val result = getNumberOfStonesAfterNBlinks(memo, 1, numBlinks - 1)
        memo[state] = result
        return result
    }

    val s = stoneNumber.toString()
    if (s.length % 2 == 0) {
        val s1 = s.substring(0, s.length / 2)
        val s2 = s.substring(s.length / 2)
        val n1 = s1.toLong()
        val n2 = s2.toLong()
        val result = getNumberOfStonesAfterNBlinks(memo, n1, numBlinks - 1) + getNumberOfStonesAfterNBlinks(
            memo,
            n2,
            numBlinks - 1
        )
        memo[state] = result
        return result
    }

    val result = getNumberOfStonesAfterNBlinks(memo, stoneNumber * 2024, numBlinks - 1)
    memo[state] = result
    return result
}

fun main() {
    val line = readln()
    val numbers = line.split(" ").map { it.toLong() }
    val memo = HashMap<Pair<Long, Int>, BigInteger>()

    var sum = BigInteger.ZERO
    for (number in numbers) {
        sum += getNumberOfStonesAfterNBlinks(memo, number, 75)
    }

    println("The answer is: $sum")
}
