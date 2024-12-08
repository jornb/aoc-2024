import System.IO (isEOF)
import Debug.Trace (traceShow)

import qualified Data.Map as Map
import qualified Data.Set as Set

type Coordinates = (Int, Int)
type Problem = (Map.Map Char [Coordinates], Set.Set Coordinates, Int, Int)

-- Get all pairs of elements, ignoring order
makePairs :: [a] -> [(a, a)]
makePairs [] = []
makePairs (x:xs) = [(x, y) | y <- xs] ++ makePairs xs

isInRange :: Coordinates -> Int -> Int -> Bool
isInRange (x, y) width height = x >= 0 && x < width && y >= 0 && y < height

parse :: [String] -> Problem
parse lines = foldl parseLine (Map.empty, Set.empty, 0, 0) (zip [0..] lines)
    where
        parseLine (antennasByType, antinodes, width, height) (y, line) = foldl (parseChar y) (antennasByType, antinodes, length line, height + 1) (zip [0..] line)
        parseChar y (antennasByType, antinodes, width, height) (x, c)
            | c == '.'  = (antennasByType, antinodes, width, height)
            | otherwise = (Map.insertWith (++) c [(x, y)] antennasByType, antinodes, width, height)


getAntinodesForPairAndDelta :: Coordinates -> Coordinates -> Int -> Int -> Set.Set Coordinates
getAntinodesForPairAndDelta (x, y) (dx, dy) width height = Set.fromList $ takeWhile (\(x', y') -> isInRange (x', y') width height) [(x + i * dx, y + i * dy) | i <- [1..]]

getAntinodesForPair :: Coordinates -> Coordinates -> Int -> Int -> Set.Set Coordinates
getAntinodesForPair (x1, y1) (x2, y2) width height = 
    let dx = x2 - x1
        dy = y2 - y1
    in Set.union (getAntinodesForPairAndDelta (x2, y2) (-dx, -dy) width height) (getAntinodesForPairAndDelta (x1, y1) (dx, dy) width height)


solveAntonodes :: [Coordinates] -> Int -> Int -> (Set.Set Coordinates, Int, Int)
solveAntonodes coordinates width height = foldl processPair (Set.empty, width, height) (makePairs coordinates)
    where
        processPair (antinodes, width, height) (p1, p2) =
            let newAntinodes = Set.filter (\coord -> isInRange coord width height) (getAntinodesForPair p1 p2 width height)
            in (Set.union antinodes newAntinodes, width, height)

solve :: Problem -> Set.Set Coordinates
solve (antennasByType, antinodes, width, height) = foldl processAntennas Set.empty (Map.toList antennasByType)
    where
        processAntennas antinodes (antennaType, coordinates) = 
            let (newAntinodes, _, _) = solveAntonodes coordinates width height
            in Set.union antinodes newAntinodes

main :: IO ()
main = do
    input <- getContents
    putStrLn $ "The answer is: " ++ show (Set.size $ solve $ parse $ lines input)
