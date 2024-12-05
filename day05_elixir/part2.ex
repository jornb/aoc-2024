defmodule Part2 do
    def solve do
        IO.stream(:stdio, :line)
        |> Enum.reduce(
            {%{:rules => [], :pages => []}, :mode1},
            fn line, {problem, mode} -> parse(line, problem, mode) end)
        |> elem(0)
        |> solve_problem()
    end

    defp parse("\n", problem, :mode1) do
        {problem, :mode2}
    end

    defp parse(line, problem, :mode1) do
        [a, b] = String.split(line, "|")
        a = String.to_integer(String.trim(a))
        b = String.to_integer(String.trim(b))
        problem = %{problem | rules: problem.rules ++ [{a, b}]}
        {problem, :mode1}
    end

    defp parse(line, problem, :mode2) do
        values = String.split(line, ",")
        values = Enum.map(values, &String.to_integer(String.trim(&1)))
        problem = %{problem | pages: problem.pages ++ [values]}
        {problem, :mode2}
    end

    defp solve_problem(problem) do
        problem.pages
        |> Enum.filter(&violates_any_rule(problem.rules, &1))
        |> Enum.map(&reorder_pages(problem.rules, &1))
        |> Enum.map(&get_middle(&1))
        |> Enum.reduce(0, fn solved, acc -> acc + solved end)
        |> (fn result -> IO.puts("The answer is: #{result}") end).()
    end

    defp reorder_pages(rules, pages) do
        reorder_pages(rules, pages, 0, 1)
    end

    defp reorder_pages(_rules, pages, ia, _ib) when ia >= length(pages) - 1 do
        pages
    end

    defp reorder_pages(rules, pages, ia, ib) when ib >= length(pages) do
        reorder_pages(rules, pages, ia + 1, ia + 2)
    end

    defp reorder_pages(rules, pages, ia, ib) do
        a = Enum.at(pages, ia)
        b = Enum.at(pages, ib)
        pages =
            if violates_any_rule(rules, a, b) do
                pages = List.replace_at(pages, ia, b)
                List.replace_at(pages, ib, a)
            else
                pages
            end
        reorder_pages(rules, pages, ia, ib + 1)
    end

    defp violates_any_rule(rules, a, b) do
        Enum.any?(rules, fn {x, y} -> x == b and y == a end)
    end

    defp violates_any_rule(rules, pages) do
        try do
            Enum.each(Enum.with_index(pages), fn {a, ia} ->
                Enum.each(Enum.with_index(pages), fn {b, ib} ->
                    if ib > ia and violates_any_rule(rules, a, b) do
                        throw(:violates_rule)
                    end
                end)
            end)
            false
        catch
            :violates_rule -> true
        end
    end

    defp get_middle(pages) do
        Enum.at(pages, div(length(pages), 2))
    end
end

Part2.solve()
