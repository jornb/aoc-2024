import scala.io.StdIn.readLine

var towels: List[String] = List()
var knownSolutions: Map[String, Long] = Map()

def findCandidates(target: String): List[String] = {
    towels.filter(towel => target.startsWith(towel))
}

def solve(target: String): Long = {
    // If we already know the solution, return it
    if (knownSolutions.contains(target)) {
        return knownSolutions(target)
    }

    var possibilities: Long = 0
    var possibleTowels = findCandidates(target)
    
    while (possibleTowels.nonEmpty) {
        // Pop the selected towel
        val selectedTowel = possibleTowels.head
        possibleTowels = possibleTowels.tail

        // Get the remaining target to be matched
        val remaining = target.substring(selectedTowel.length)

        // If nothing remaining, we're done
        if (remaining.isEmpty) {
            possibilities += 1
        } else {
            possibilities += solve(remaining)
        }
    }

    knownSolutions += (target -> possibilities)
    return possibilities
}

@main def main() = {
    towels = readLine().split(", ").toList
    readLine()
    
    var sum: Long = 0
    Iterator.continually(readLine()).takeWhile(_ != null).foreach { target =>
        val solutions = solve(target)
        sum += solutions
    }
    println(s"The answer is: $sum")
}
