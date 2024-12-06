module Part1

open System
open System.IO

type Problem = { map: char list list; pos: (int * int); dir: (int * int); count: int }

let extractStartPosition problem =
    problem.map
    |> List.mapi (fun i row -> row |> List.mapi (fun j cell -> if cell = '^' then Some (i, j) else None))
    |> List.collect id
    |> List.choose id
    |> List.head
    |> fun p -> { problem with pos = p }

let turn dir = 
    match dir with
    | (-1, 0) -> (0, 1)
    | (0, 1) -> (1, 0)
    | (1, 0) -> (0, -1)
    | (0, -1) -> (-1, 0)
    | _ -> failwith "Invalid direction"

let markPosition map i j =
    map
    |> List.mapi (fun ii row -> 
        if ii = i then 
            row |> List.mapi (fun jj cell -> if jj = j then '@' else cell) 
        else row)

let solve problem =
    let rec move problem =
        let (i, j) = problem.pos
        let (di, dj) = problem.dir
        let (ni, nj) = (i + di, j + dj)
        match (ni, nj) with
        | a, b when a < 0 || a >= List.length problem.map || b < 0 || b >= List.length (List.head problem.map) -> problem
        | _ -> 
            let cell = List.item ni problem.map |> List.item nj
            match cell with
            | '#' -> { problem with dir = turn problem.dir; } |> move
            | '.' -> 
                { problem with map = markPosition problem.map ni nj; pos = (ni, nj); count = problem.count + 1 } |> move
            | _ -> { problem with pos = (ni, nj) } |> move
    problem |> move

Console.In.ReadToEnd().Split('\n')
|> Array.filter (fun x -> x.Length > 0)
|> Array.map (fun line -> line.ToCharArray() |> Array.toList)
|> Array.toList
|> fun map -> { map = map; pos = (0, 0); dir = (-1, 0); count = 1 }
|> extractStartPosition
|> solve
|> fun problem -> printfn "The answer is: %d" problem.count
