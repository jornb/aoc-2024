module Part1

open System
open System.IO

type Problem = { rules: (int * int) list; pages: int list list }

let parse (problem, mode) line =
    match line, mode with
    | "", "mode1" -> problem, "mode2"
    | "", _ -> problem, mode
    | line, "mode1" ->
        let parts = line.Split('|')
        let a = Int32.Parse(parts.[0].Trim())
        let b = Int32.Parse(parts.[1].Trim())
        { problem with rules = (a, b) :: problem.rules }, "mode1"
    | line, "mode2" ->
        let values = line.Split(',')
        let values2 = values |> Array.map (fun v -> Int32.Parse(v.Trim())) |> Array.toList
        { problem with pages = values2 :: problem.pages }, "mode2"
    | _ -> problem, mode

let violatesAnyRule rules pages =
    try
        pages |> List.iteri (fun ia a ->
            pages |> List.iteri (fun ib b ->
                if ib > ia && (rules |> List.exists (fun (x, y) -> x = b && y = a)) then
                    raise (Exception "violates_rule")
            )
        )
        false
    with
    | _ -> true

let getMiddle pages =
    pages |> List.item (List.length pages / 2)

let solveProblem problem =
    problem.pages
    |> List.filter (fun pages -> not (violatesAnyRule problem.rules pages))
    |> List.map getMiddle
    |> List.sum
    |> printfn "The answer is: %d"

let solve () =
    Console.In.ReadToEnd().Split('\n')
    |> Array.fold parse ({ rules = []; pages = [] }, "mode1")
    |> fst
    |> solveProblem

solve()
