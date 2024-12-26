parsed_initial = false
initial_values = Dict()
connections = []
all_names = Set()

while !eof(stdin)
    line = readline(stdin)

    if line == ""
        global parsed_initial = true
    elseif !parsed_initial
        name, value = split(line, ": ")
        initial_values[name] = parse(Int, value)
    else
        tokens = split(line, " ")
        push!(connections, (tokens[1], tokens[2], tokens[3], tokens[5]))

        # Add to all names
        push!(all_names, tokens[1])
        push!(all_names, tokens[3])
        push!(all_names, tokens[5])
    end
end


function process(known_values, remaining_values, connections)
    processed_values = []
    for (lhs, op, rhs, out) in connections
        # Don't reprocess
        if out in keys(known_values)
            continue
        end

        # Require all inputs to be known
        if !(lhs in keys(known_values) && rhs in keys(known_values))
            continue
        end

        lhs_val = known_values[lhs]
        rhs_val = known_values[rhs]
        result = 0
        if op == "AND"
            result = lhs_val & rhs_val
        elseif op == "OR"
            result = lhs_val | rhs_val
        elseif op == "XOR"
            result = lhs_val ⊻ rhs_val
        end

        known_values[out] = result
        push!(processed_values, out)
        delete!(remaining_values, out)
    end

    return length(processed_values) > 0
end

function dict_to_value(dict)
    value = 0
    for (name, bit) in dict
        num = parse(Int, name[2:end])
        value |= bit << num
    end
    return value
end

values = initial_values
while process(values, all_names, connections)
end

# Select all values with name starting with z
z_values = filter(x -> startswith(x[1], "z"), values)
val = dict_to_value(z_values)
println("The answer is $val")