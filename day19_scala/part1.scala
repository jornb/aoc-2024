import scala.io.StdIn.readLine

var towels: List[String] = List()
var knownSolutions: Map[String, Option[String]] = Map()

def findCandidates(target: String): List[String] = {
    towels.filter(towel => target.startsWith(towel))
}

def solve(target: String): Option[String] = {
    // If we already know the solution, return it
    if (knownSolutions.contains(target)) {
        return knownSolutions(target)
    }

    var possibleTowels = findCandidates(target)
    
    while (possibleTowels.nonEmpty) {
        // Pop the selected towel
        val selectedTowel = possibleTowels.head
        possibleTowels = possibleTowels.tail

        // Get the remaining target to be matched
        val remaining = target.substring(selectedTowel.length)

        // If nothing remaining, we're done
        if (remaining.isEmpty) {
            knownSolutions += (target -> Some(selectedTowel))
            return Some(selectedTowel)
        }

        // Recursively check remaining
        var solution = solve(remaining)
        if (solution.isDefined) {
            knownSolutions += (target -> Some(selectedTowel))
            return Some(selectedTowel + ", " + solution.get)
        }
    }

    knownSolutions += (target -> None)
    return None
}

@main def main() = {
    towels = readLine().split(", ").toList
    readLine()
    
    var count = 0
    Iterator.continually(readLine()).takeWhile(_ != null).foreach { target =>
        val solution = solve(target)
        if (solution.isDefined) {
            count += 1
        }
    }
    println(s"The answer is: $count")
}
